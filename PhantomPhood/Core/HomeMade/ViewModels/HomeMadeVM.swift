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
        
        taskManager.newTask(.init(title: "New Homemade Content", medias: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediasUsecase: .placeReview, onReadyToSubmit: { medias in
            guard let medias else {
                throw URLError(.badURL)
            }
            
            let mediaIds = UploadManager.getMediaIds(from: medias)
            
            do {
                try await self.homemadeDM.createHomeMadeContent(body: .init(content: self.content, media: mediaIds, tags: self.tags.map({ $0.id })))
                self.finished = true
                self.toastVM.toast(.init(type: .success, title: "Success", message: "We got it 🙌🏻"))
            } catch {
                self.toastVM.toast(.init(type: .error, title: "Success", message: "Couldn't submit your content :("))
            }
            
            self.loadingSections.remove(.submitting)
        }, onError: { error in
            self.toastVM.toast(.init(type: .error, title: "Review", message: "Couldn't submit your conetnt :("))
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
