//
//  NewCheckInVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/31/24.
//

import Foundation

final class NewCheckInVM: ObservableObject, LoadingSections {
    private let checkInDM = CheckInDM()
    
    private let placeIdentifier: PlaceIdentifier
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published private(set) var place: PlaceEssentials? = nil
    @Published private(set) var event: Event? = nil
    
    @Published var tabSelection: Tab = .mediaAndCaption
    @Published var presentedSheet: Sheets? = nil
    @Published var savedImageId: String? = nil
    
    @Published var privacyType: PrivacyType = .PUBLIC
    @Published var caption: String = ""
    @Published var scores: [RatingItem:Int] = [:]
    @Published var mentions: [UserEssentials] = []
    
    @Published private(set) var error: Error?
    
    init(placeIdentifier: PlaceIdentifier) {
        self.placeIdentifier = placeIdentifier
        
        Task { [weak self] in
            self?.setLoadingState(.fetchPlace, to: true)
            
            defer {
                self?.setLoadingState(.fetchPlace, to: false)
            }
            
            do {
                let placeOverview = try await self?.placeIdentifier.getOverview()
                
                guard let self, let placeOverview else { return }
                
                DispatchQueue.main.async {
                    self.place = PlaceEssentials(placeOverview: placeOverview)
                }
            } catch {
                self?.error = error
            }
        }
    }
    
    init(event: Event) {
        self.placeIdentifier = .essentials(event.place)
        self.event = event
        self.place = event.place
    }
    
    func updatePlaceLocationInfo() {
        Task { [weak self] in
            await self?.place?.location.updateLocationInfo()
        }
    }
    
    func getSecondaryActionTitle() -> String {
        switch tabSelection {
        case .mediaAndCaption:
            return "Cancel"
        case .details, .rating:
            return "Previous"
        }
    }
    
    func getPrimaryActionTitle(selctedMediaCount: Int) -> String {
        switch tabSelection {
        case .mediaAndCaption:
            return (!caption.isEmpty || selctedMediaCount > 0) ? "Next" : "Skip"
        case .details:
            return "Next"
        case .rating:
            return "Submit (\(privacyType.title))"
        }
    }
    
    func submit(mediaItems: [PickerMediaItem]) async {
        guard let place, !loadingSections.contains(.submitting) else { return }
        
        setLoadingState(.submitting, to: true)
        
        let task = AsyncTask(title: "New Check In", pickerMediaItems: mediaItems, mediaUsecase: .checkIn) { mediaItems in
            let media = UploadManager.getMediaIds(from: mediaItems)
            
            do {
                let scores = CheckInDM.CheckinRequestBody.Scores(
                    overall: self.scores[.overall],
                    drinkQuality: self.scores[.drinkQuality],
                    foodQuality: self.scores[.foodQuality],
                    service: self.scores[.service],
                    atmosphere: self.scores[.atmosphere],
                    value: self.scores[.value]
                )
                
                let body: CheckInDM.CheckinRequestBody = if let event = self.event {
                    .init(event: event.id, privacyType: self.privacyType, tags: self.mentions.compactMap({ $0.id }), caption: self.caption, media: media?.compactMap({ $0.uploadId }), scores: scores)
                } else {
                    .init(place: place.id, privacyType: self.privacyType, tags: self.mentions.compactMap({ $0.id }), caption: self.caption, media: media?.compactMap({ $0.uploadId }), scores: scores)
                }
                
                try await self.checkInDM.checkin(body: body)
                
                ToastVM.shared.toast(.init(type: .success, title: "Success", message: "Checked in"))
                HapticManager.shared.notification(type: .success)
            } catch {
                presentErrorToast(error)
            }
            
            self.setLoadingState(.submitting, to: false)
        } onError: { err in
            presentErrorToast(err)
            self.setLoadingState(.submitting, to: false)
        }
        
        TaskManager.shared.newTask(task)
    }
    
    // MARK: Enums
    
    enum Tab {
        case mediaAndCaption
        case details
        case rating
    }
    
    enum LoadingSection {
        case fetchPlace
        case submitting
    }
    
    enum Sheets {
        case camera
        case photosPicker
        case userSelector
    }
    
    enum RatingItem: String, CaseIterable {
        case overall
        case drinkQuality
        case foodQuality
        case service
        case atmosphere
        case value
        
        var title: String {
            switch self {
            case .overall:
                "Overall"
            case .drinkQuality:
                "Drink Quality"
            case .foodQuality:
                "Food Quality"
            case .service:
                "Service"
            case .atmosphere:
                "Atmosphere"
            case .value:
                "Value"
            }
        }
    }
}
