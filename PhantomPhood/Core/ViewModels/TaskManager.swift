//
//  TaskManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation

final class TaskManager: ObservableObject {
    static let imageCompressionRate: CGFloat = 0.7
    static let maxImageSize = CGSize(width: 1080, height: 1920)
    static let maxVideoWidth: CGFloat = 1080
    static let videoAspectRatio = CGSize(width: 9, height: 16)
    
    static let shared = TaskManager()
    
    private let uploadManager = UploadManager.shared
    
    @Published private(set) var tasks: [AsyncTask] = []
    
    private init() {}
    
    var isProcessing: Bool {
        tasks.contains {
            if case .processing = $0.status {
                true
            } else {
                false
            }
        }
    }
    
    var activeTask: AsyncTask? {
        tasks.first {
            if case .processing = $0.status {
                true
            } else {
                false
            }
        }
    }
    
    func newTask(_ task: AsyncTask) {
        DispatchQueue.main.async {
            self.tasks.append(task)
            
            if !self.isProcessing {
                Task {
                    await self.startNextTask()
                }
            }
        }
    }
    
    func updateTaskMediaStatus(taskId: String, media: AsyncTaskMedia) async {
        await MainActor.run {
            self.tasks = self.tasks.map {
                if $0.id == taskId {
                    var updatedTask = $0
                    updatedTask.mediaItems = $0.mediaItems.map({ tasksMedia in
                        if tasksMedia.id == media.id {
                            return media
                        } else {
                            return tasksMedia
                        }
                    })
                    
                    return updatedTask
                } else {
                    return $0
                }
            }
        }
    }
    
    func removeTaskMedia(task: AsyncTask, mediaId: String) async {
        await MainActor.run {
            self.tasks = self.tasks.map {
                if $0.id == task.id {
                    var updatedTask = task
                    updatedTask.mediaItems = $0.mediaItems.filter({ tasksMedia in
                        return tasksMedia.id != mediaId
                    })
                    
                    return updatedTask
                } else {
                    return $0
                }
            }
        }
    }
    
    /// Checks to see if all the media items are at their **.uploaded** state
    func isTaskReadyToSubmit(task: AsyncTask) -> Bool {
        return task.mediaItems.allSatisfy { media in
            if case .uploaded(_, _, _) = media {
                return true
            } else {
                return false
            }
        }
    }
    
    /// Calls the task's `onReadyToSubmit` function if `isTaskReadyToSubmit` is true
    /// - Calls the `startNextTask` at the end
    func submitIfReady(taskId: String) async throws {
        if let task = self.tasks.first(where: { $0.id == taskId }) {
            if isTaskReadyToSubmit(task: task) {
                try await task.onReadyToSubmit(task.mediaItems.isEmpty ? nil : task.mediaItems)
                await MainActor.run {
                    self.tasks.removeAll { $0.id == taskId }
                }
            }
        }
        
        await startNextTask()
    }
    
    func handleTaskFailure(taskId: String, error: Error) async {
        if let task = self.tasks.first(where: { $0.id == taskId }) {
            if let onError = task.onError {
                onError(error)
            }
            
            await MainActor.run {
                self.tasks.removeAll { $0.id == taskId }
            }
        }
        
        await startNextTask()
    }
    
    private func uploadMediaItem(
        compressedMediaData: CompressedMediaData,
        usecase: UploadManager.UploadUseCase
    ) async -> UploadManager.ResponseData? {
        return try? await uploadManager.uploadMedia(media: compressedMediaData, usecase: usecase)
    }
    
    @MainActor
    private func startNextTask() async {
        guard let nextIndex = self.tasks.firstIndex(where: { $0.status == .pending }) else { return }
        
        var nextTask = self.tasks[nextIndex]
        
        do {
            self.tasks = self.tasks.compactMap {
                if $0.id == nextTask.id {
                    nextTask.status = .processing(startedAt: .now)
                    return nextTask
                } else {
                    return $0
                }
            }
            
            guard !nextTask.mediaItems.isEmpty, let mediaUsecase = nextTask.mediaUsecase else {
                try await submitIfReady(taskId: nextTask.id)
                return
            }
            
            for media in nextTask.mediaItems {
                if case .uncompressed(let mediaItemData) = media {
                    switch mediaItemData.state {
                    case .image(let uiImage):
                        // Convert Image
                        if
                            let resizedImage = ImageHelper.resize(
                                uiImage: uiImage,
                                targetSize: Self.maxImageSize
                            ),
                            let data = ImageHelper.compress(
                                uiImage: resizedImage,
                                compressionQuality: TaskManager.imageCompressionRate
                            ) {
                            await updateTaskMediaStatus(
                                taskId: nextTask.id,
                                media: .compressed(
                                    compressedMediaData: .image(data),
                                    mediaItemData: mediaItemData
                                )
                            )
                            
                            Task {
                                // Start upload
                                await updateTaskMediaStatus(
                                    taskId: nextTask.id,
                                    media: .uploading(
                                        compressedMediaData: .image(data),
                                        mediaItemData: mediaItemData
                                    )
                                )
                                
                                if let uploadResponse = await uploadMediaItem(
                                    compressedMediaData: .image(data),
                                    usecase: mediaUsecase
                                ) {
                                    await updateTaskMediaStatus(
                                        taskId: nextTask.id,
                                        media: .uploaded(
                                            tasksMediaAPIResponseData: uploadResponse,
                                            compressedMediaData: .image(data),
                                            mediaItemData: mediaItemData
                                        )
                                    )
                                } else {
                                    await removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                                }
                                
                                try await submitIfReady(taskId: nextTask.id)
                            }
                        } else {
                            await removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                            
                            // Submit if ready
                            try await submitIfReady(taskId: nextTask.id)
                        }
                    case .movie(let inputURL):
                        // Convert Movie
                        let outputFileName = media.id.replacingOccurrences(of: "/", with: "-") + ".mp4"
                        
                        do {
                            let outputURL = try await VideoHelper.compress(
                                inputURL: inputURL,
                                aspectRatio: Self.videoAspectRatio,
                                maxWidth: Self.maxVideoWidth,
                                outputFileName: outputFileName
                            )
                            
                            await updateTaskMediaStatus(
                                taskId: nextTask.id,
                                media: .compressed(
                                    compressedMediaData: .movie(outputURL),
                                    mediaItemData: mediaItemData
                                )
                            )
                            
                            Task {
                                // Start upload
                                await updateTaskMediaStatus(
                                    taskId: nextTask.id,
                                    media: .uploading(
                                        compressedMediaData: .movie(outputURL),
                                        mediaItemData: mediaItemData
                                    )
                                )
                                
                                if let uploadResponse = await uploadMediaItem(
                                    compressedMediaData: .movie(outputURL),
                                    usecase: mediaUsecase
                                ) {
                                    await updateTaskMediaStatus(
                                        taskId: nextTask.id,
                                        media: .uploaded(
                                            tasksMediaAPIResponseData: uploadResponse,
                                            compressedMediaData: .movie(outputURL),
                                            mediaItemData: mediaItemData
                                        )
                                    )
                                } else {
                                    await removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                                }
                                
                                // Submit if ready
                                try await submitIfReady(taskId: nextTask.id)
                            }
                        } catch {
                            presentErrorToast(error, debug: "Error Compressing video", silent: true)
                            await removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                            
                            // Submit if ready
                            try await submitIfReady(taskId: nextTask.id)
                        }
                    }
                }
            }
        } catch {
            presentErrorToast(error, silent: true)
            
            await handleTaskFailure(taskId: nextTask.id, error: error)
        }
    }
    
    enum TaskStatus: Equatable {
        case pending
        case processing(startedAt: Date = .now)
    }
}


enum AsyncTaskMedia: Identifiable {
    case uncompressed(mediaItemData: MediaItemData)
    case compressed(compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    case uploading(compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    case uploaded(tasksMediaAPIResponseData: UploadManager.ResponseData, compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    
    var id: String {
        switch self {
        case .uncompressed(let mediaItemData):
            mediaItemData.id
        case .compressed( _, let mediaItemData):
            mediaItemData.id
        case .uploading( _, let mediaItemData):
            mediaItemData.id
        case .uploaded( _, _, let mediaItemData):
            mediaItemData.id
        }
    }
    
    var mediaId: UploadManager.MediaIds? {
        if case .uploaded(let response, _, _) = self {
            return UploadManager.MediaIds(uploadId: response.id , caption: "")
        }
        
        return nil
    }
}

enum CompressedMediaData {
    case image(Data)
    case movie(URL)
}

struct AsyncTask {
    let id = UUID().uuidString
    var status: TaskManager.TaskStatus = .pending
    let title: String
    var mediaItems: [AsyncTaskMedia]
    let mediaUsecase: UploadManager.UploadUseCase?
    var onReadyToSubmit: ([AsyncTaskMedia]?) async throws -> Void
    var onError: ((Error) -> Void)?
    
    init(
        title: String,
        mediaItems: [AsyncTaskMedia],
        mediaUsecase: UploadManager.UploadUseCase?,
        onReadyToSubmit: @escaping ([AsyncTaskMedia]?) async throws -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        self.title = title
        self.mediaItems = mediaItems
        self.mediaUsecase = mediaUsecase
        self.onReadyToSubmit = onReadyToSubmit
        self.onError = onError
    }
    
    init(
        title: String,
        pickerMediaItems: [PickerMediaItem],
        mediaUsecase: UploadManager.UploadUseCase?,
        onReadyToSubmit: @escaping ([AsyncTaskMedia]?) async throws -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        self.title = title
        self.mediaItems = pickerMediaItems.compactMap({
            if case .loaded(let mediaData) = $0.state {
                return AsyncTaskMedia.uncompressed(mediaItemData: .init(id: $0.id, state: mediaData))
            } else {
                return nil
            }
        })
        self.mediaUsecase = mediaUsecase
        self.onReadyToSubmit = onReadyToSubmit
        self.onError = onError
    }
    
    var completionRate: Double {
        switch status {
        case .pending:
            return 0
        case let .processing(startedAt):
            let naturalProgress = 1 - exp(startedAt.timeIntervalSince(.now) / 3)
            
            let mediaCompletion: Double = if mediaItems.isEmpty {
                naturalProgress
            } else {
                Double(mediaItems.filter {
                    if case .uploaded = $0 {
                        return true
                    } else {
                        return false
                    }
                }.count) / Double(mediaItems.count)
            }
            
            return (naturalProgress * 0.4) + (mediaCompletion * 0.6)
        }
    }
}
