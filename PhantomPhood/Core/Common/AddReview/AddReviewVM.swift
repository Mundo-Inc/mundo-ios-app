//
//  AddReviewVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/9/23.
//

import Foundation
import SwiftUI

@MainActor
final class AddReviewVM: ObservableObject {
    enum Steps {
        case recommendation
        case scores
        case review
    }
    
    private let toastVM = ToastVM.shared
    private let taskManager = TaskManager.shared
    private let placeDM = PlaceDM()
    private let reviewDM = ReviewDM()
    
    @Published var step: Steps = .recommendation
    
    @Published var isRecommended: Bool? = nil
    @Published var overallScore: Int? = nil
    @Published var foodQuality: Int? = nil
    @Published var drinkQuality: Int? = nil
    @Published var service: Int? = nil
    @Published var atmosphere: Int? = nil
    
    @Published var isPublic = true
    @Published var reviewContent = ""
    
    @Published var isSubmitting = false

    @Published var isPresented: Bool = false
    @Published var place: PlaceEssentials? = nil
    @Published var error: String? = nil
    
    init(idOrData: IdOrData<PlaceEssentials>) {
        switch idOrData {
        case .id(let placeId):
            Task { [weak self] in
                do {
                    let placeOverview = try await self?.placeDM.getOverview(id: placeId)
                    if let placeOverview {
                        self?.place = PlaceEssentials(placeOverview: placeOverview)
                    } else {
                        self?.error = "Not Found"
                    }
                } catch {
                    self?.error = "Couldn't fetch place data"
                }
            }
            break
        case .data(let placeData):
            self.place = placeData
            break
        }
    }
    
    init(mapPlace: MapPlace) {
        Task { [weak self] in
            do {
                let placeData = try await self?.placeDM.fetch(mapPlace: mapPlace)
                if let placeData {
                    self?.place = PlaceEssentials(placeDetail: placeData)
                } else {
                    self?.error = "Not Found"
                }
            } catch {
                self?.error = "Couldn't fetch place data"
            }
        }
    }
    
    var haveAnyScore: Bool {
        [overallScore, foodQuality, drinkQuality, service, atmosphere].contains(where: { $0 != nil })
    }

    var haveAllScores: Bool {
        [overallScore, foodQuality, drinkQuality, service, atmosphere].allSatisfy({ $0 != nil })
    }

    func submit(mediaItems: [MediaItem]) async {
        guard let place, !isSubmitting else { return }
        
        self.isSubmitting = true
        
        taskManager.newTask(.init(title: "Add Review", medias: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediasUsecase: .placeReview, onReadyToSubmit: { medias in
            let images: [UploadManager.MediaIds]
            let videos: [UploadManager.MediaIds]
            if let medias {
                images = UploadManager.getMediaIds(from: medias, type: .image)
                videos = UploadManager.getMediaIds(from: medias, type: .video)
            } else {
                images = []
                videos = []
            }
                        
            do {
                try await self.reviewDM.addReview(.init(place: place.id, scores: .init(overall: self.overallScore, drinkQuality: self.drinkQuality, foodQuality: self.foodQuality, service: self.service, atmosphere: self.atmosphere, value: nil), content: self.reviewContent, recommend: self.isRecommended, images: images, videos: videos))
                
                self.toastVM.toast(.init(type: .success, title: "Review", message: "We got your review 🙌🏻 Thanks!"))
                self.place = nil
            } catch {
                self.toastVM.toast(.init(type: .error, title: "Review", message: "Couldn't submit your review :("))
            }
            self.isSubmitting = false
        }, onError: { error in
            self.toastVM.toast(.init(type: .error, title: "Review", message: "Couldn't submit your review :("))
        }))
    }
}

