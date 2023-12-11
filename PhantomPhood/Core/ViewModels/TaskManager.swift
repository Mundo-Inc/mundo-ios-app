//
//  TaskManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation

@MainActor
final class TaskManager: ObservableObject {
    static let imageCompressionRate: CGFloat = 0.7
    static let shared = TaskManager()
    
    let uploadManager = UploadManager.shared
    
    @Published private(set) var tasks: [Tasks] = []
    
    private init() {}
    
    var isProcessing: Bool {
        tasks.contains { $0.status == .processing }
    }
    
    func newTask(_ task: Tasks) {
        self.tasks.append(task)
        
        if !self.isProcessing {
            Task {
                await self.startNextTask()
            }
        }
    }
    
    func updateTaskMediaStatus(task: Tasks, media: TasksMedia) {
        self.tasks = self.tasks.map {
            if $0.id == task.id {
                var updatedTask = task
                updatedTask.medias = $0.medias.map({ tasksMedia in
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
    
    func removeTaskMedia(task: Tasks, mediaId: String) {
        self.tasks = self.tasks.map {
            if $0.id == task.id {
                var updatedTask = task
                updatedTask.medias = $0.medias.filter({ tasksMedia in
                    return tasksMedia.id != mediaId
                })
                
                return updatedTask
            } else {
                return $0
            }
        }
    }
    
    /// Checks to see if all the medias are at their **.uploaded** state
    func isTaskReadyToSubmit(task: Tasks) -> Bool {
        return task.medias.allSatisfy { media in
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
                try await task.onReadyToSubmit(task.medias.isEmpty ? nil : task.medias)
                self.tasks.removeAll { task in
                    task.id == taskId
                }
            }
        }
        
        await startNextTask()
    }
    
    private func uploadMediaItem(compressedMediaData: CompressedMediaData, usecase: UploadManager.UploadUseCase) async -> UploadManager.APIResponse.ResponseData? {
        let uploadResponse = try? await uploadManager.uploadMedia(media: compressedMediaData, usecase: usecase)
        
        return uploadResponse
    }
    
    private func startNextTask() async {
        guard let nextIndex = self.tasks.firstIndex(where: { task in
            task.status == .pending
        }) else { return }
        
        var nextTask = self.tasks[nextIndex]
        
        do {
            self.tasks = self.tasks.compactMap {
                if $0.id == nextTask.id {
                    nextTask.status = .processing
                    return nextTask
                } else {
                    return $0
                }
            }
            
            guard !nextTask.medias.isEmpty else {
                try await submitIfReady(taskId: nextTask.id)
                return
            }
            for media in nextTask.medias {
                if case .uncompressed(let mediaItemData) = media {
                    switch mediaItemData.state {
                    case .image(let uiImage):
                        // Convert Image
                        if let data = ImageHelper.compress(uiImage: uiImage, compressionQuality: TaskManager.imageCompressionRate) {
                            updateTaskMediaStatus(task: nextTask, media: .compressed(compressedMediaData: .image(data), mediaItemData: mediaItemData))
                            
                            Task {
                                // Start upload
                                updateTaskMediaStatus(task: nextTask, media: .uploading(compressedMediaData: .image(data), mediaItemData: mediaItemData))
                                let uploadResponse = await uploadMediaItem(compressedMediaData: .image(data), usecase: .placeReview)
                                if let uploadResponse {
                                    updateTaskMediaStatus(task: nextTask, media: .uploaded(tasksMediaAPIResponseData: uploadResponse, compressedMediaData: .image(data), mediaItemData: mediaItemData))
                                } else {
                                    removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                                }
                                
                                // Submit if ready
                                try await submitIfReady(taskId: nextTask.id)
                            }
                        } else {
                            print("Error Compressing image")
                            removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                            
                            // Submit if ready
                            try await submitIfReady(taskId: nextTask.id)
                        }
                    case .movie(let inputURL):
                        // Convert Movie
                        let aspectRatio: CGSize = CGSize(width: 9, height: 16)
                        let maxWidth: CGFloat = 1080
                        let outputFileName = media.id.replacingOccurrences(of: "/", with: "-") + ".mp4"
                        
                        do {
                            let outputURL = try await VideoHelper.compress(inputURL: inputURL, aspectRatio: aspectRatio, maxWidth: maxWidth, outputFileName: outputFileName)
                            if let data1 = try? Data(contentsOf: inputURL), let data2 = try? Data(contentsOf: outputURL) {
                                print("Original  : \(String(format: "%.2f", Double(data1.count) / 1024 / 1024)) MB\nCompressed: \(String(format: "%.2f", Double(data2.count) / 1024 / 1024)) MB\n\t-------------------\n\t|   Rate: %\(String(format: "%.1f", 100 * (1.0 - Double(data2.count) / Double(data1.count))))   |\n\t-------------------")
                            }
                            updateTaskMediaStatus(task: nextTask, media: .compressed(compressedMediaData: .movie(outputURL), mediaItemData: mediaItemData))
                            
                            Task {
                                // Start upload
                                updateTaskMediaStatus(task: nextTask, media: .uploading(compressedMediaData: .movie(outputURL), mediaItemData: mediaItemData))
                                let uploadResponse = await uploadMediaItem(compressedMediaData: .movie(outputURL), usecase: .placeReview)
                                if let uploadResponse {
                                    updateTaskMediaStatus(task: nextTask, media: .uploaded(tasksMediaAPIResponseData: uploadResponse, compressedMediaData: .movie(outputURL), mediaItemData: mediaItemData))
                                } else {
                                    removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                                }
                                
                                // Submit if ready
                                try await submitIfReady(taskId: nextTask.id)
                            }
                        } catch {
                            print("Error Compressing video")
                            removeTaskMedia(task: nextTask, mediaId: mediaItemData.id)
                            
                            // Submit if ready
                            try await submitIfReady(taskId: nextTask.id)
                        }
                    }
                }
            }
        } catch {
            if let onError = nextTask.onError {
                onError(error)
            }
            await startNextTask()
        }
    }
}

enum TasksStatus: Equatable {
    case pending
    case processing
}

enum TasksMedia: Identifiable {
    case uncompressed(mediaItemData: MediaItemData)
    case compressed(compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    case uploading(compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    case uploaded(tasksMediaAPIResponseData: UploadManager.APIResponse.ResponseData, compressedMediaData: CompressedMediaData, mediaItemData: MediaItemData)
    
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
}

enum CompressedMediaData {
    case image(Data)
    case movie(URL)
}

struct Tasks {
    let id = UUID().uuidString
    var status: TasksStatus = .pending
    let title: String
    var medias: [TasksMedia]
    let mediasUsecase: UploadManager.UploadUseCase?
    var onReadyToSubmit: ([TasksMedia]?) async throws -> Void
    var onError: ((Error) -> Void)?
    
}
