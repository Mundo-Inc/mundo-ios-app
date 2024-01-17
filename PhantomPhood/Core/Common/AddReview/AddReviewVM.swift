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
    static let shared = AddReviewVM()
    
    private init () {}
    
    enum Steps {
        case recommendation
        case scores
        case review
    }
    
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    private let toastViewModel = ToastVM.shared
    private let taskManager = TaskManager.shared
    private let placeDM = PlaceDM()
    
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
    @Published var place: Place? = nil
    @Published var error: String? = nil
    
    var haveAnyScore: Bool {
        [overallScore, foodQuality, drinkQuality, service, atmosphere].contains(where: { $0 != nil })
    }

    /// Used on isPresented of the add review sheet
    var isPresentedHandler: Binding<Bool> {
        .init {
            self.isPresented
        } set: { value in
            if !value {
                self.place = nil
                self.isPresented = false
            }
        }
    }

    /// Used to present the add review sheet from a place
    func present(place: Place) {
        isPresented = true
        self.place = place
    }

    /// Used to present the add review sheet from a place id
    func present(placeId: String) {
        isPresented = true
        Task {
            do {
                let placeData = try await placeDM.fetch(id: placeId)
                self.place = placeData
            } catch {
                self.error = "Couldn't fetch place data"
            }
        }
    }
    
    func submit(mediaItems: [MediaItem]) async {
        guard let place, !isSubmitting, let token = await auth.getToken() else {
            if !isSubmitting {
                toastViewModel.toast(.init(type: .error, title: "Authentication failed", message: "Where is the token?!!! well, this is a bug"))
            }
            return
        }
        
        self.isSubmitting = true
        
        struct RequestBody: Encodable {
            let place: String
            let scores: ScoresBody
            let content: String
            let recommend: Bool?
            let images: [UploadManager.MediaIds]
            let videos: [UploadManager.MediaIds]
            
            struct ScoresBody: Encodable {
                let overall: Int?
                let drinkQuality: Int?
                let foodQuality: Int?
                let service: Int?
                let atmosphere: Int?
                let value: Int?
            }
        }
        
        taskManager.newTask(.init(title: "Add Review", medias: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediasUsecase: .placeReview, onReadyToSubmit: { medias in
            let body: Data
            if let medias {
                let images = UploadManager.getMediaIds(from: medias, type: .image)
                let videos = UploadManager.getMediaIds(from: medias, type: .video)
                
                body = try self.apiManager.createRequestBody(RequestBody(place: place.id, scores: .init(overall: self.overallScore, drinkQuality: self.drinkQuality, foodQuality: self.foodQuality, service: self.service, atmosphere: self.atmosphere, value: nil), content: self.reviewContent, recommend: self.isRecommended, images: images, videos: videos))
            } else {
                body = try self.apiManager.createRequestBody(RequestBody(place: place.id, scores: .init(overall: self.overallScore, drinkQuality: self.drinkQuality, foodQuality: self.foodQuality, service: self.service, atmosphere: self.atmosphere, value: nil), content: self.reviewContent, recommend: self.isRecommended, images: [], videos: []))
            }
            
            do {
                try await self.apiManager.requestNoContent("/reviews", method: .post, body: body, token: token)
                
                self.toastViewModel.toast(.init(type: .success, title: "Review", message: "We got your review 🙌🏻 Thanks!"))
                self.place = nil
            } catch {
                self.toastViewModel.toast(.init(type: .error, title: "Review", message: "Couldn't submit your review :("))
            }
            self.isSubmitting = false
        }, onError: { error in
            self.toastViewModel.toast(.init(type: .error, title: "Review", message: "Couldn't submit your review :("))
        }))
    }
}

