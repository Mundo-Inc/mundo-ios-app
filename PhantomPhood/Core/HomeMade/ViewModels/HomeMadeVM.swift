//
//  HomeMadeVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/12/24.
//

import Foundation

@MainActor
final class HomeMadeVM: ObservableObject {
    private let taskManager = TaskManager.shared
    private let toastVM = ToastVM.shared
    private let homemadeDM = HomeMadeDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var presentedSheet: Sheets? = nil
    
    @Published var content = ""
    @Published var tags: [UserEssentials] = []
    
    @Published var finished = false
    
    func submit(mediaItems: [PickerMediaItem]) async {
        guard !self.loadingSections.contains(.submitting) else { return }
        
        self.loadingSections.insert(.submitting)
        
        taskManager.newTask(.init(title: "New Homemade Content", mediaItems: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediaUsecase: .placeReview, onReadyToSubmit: { mediaItems in
            guard let mediaItems else {
                throw URLError(.badURL)
            }
            
            let mediaIds = UploadManager.getMediaIds(from: mediaItems)
            
            do {
                try await self.homemadeDM.createHomeMadeContent(body: .init(content: self.content, media: mediaIds, tags: self.tags.map({ $0.id })))
                self.finished = true
                self.toastVM.toast(.init(type: .success, title: "Success", message: "We got it 🙌🏻"))
            } catch {
                presentErrorToast(error)
            }
            
            self.loadingSections.remove(.submitting)
        }, onError: { error in
            presentErrorToast(error)
        }))
    }
    
    enum LoadingSection {
        case submitting
    }
    
    enum Sheets {
        case photosPicker
        case userSelector
    }
}
