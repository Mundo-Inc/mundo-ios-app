//
//  NewCheckinVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/25/24.
//

import Foundation
import SwiftUI

final class NewCheckinVM: ObservableObject {
    private let toastVM = ToastVM.shared
    private let taskManager = TaskManager.shared
    private let placeDM = PlaceDM()
    private let checkInDM = CheckInDM()
    
    @Published var privacyType: PrivacyType = .PUBLIC
    @Published var caption: String = ""
    @Published var mentions: [UserEssentials] = []
    
    @Published var presentedSheet: Sheets? = nil
    @Published var savedImageId: String? = nil
    
    @Published var isAdvancedSettingsVisible: Bool = false
    
    @Published private(set) var place: PlaceEssentials? = nil
    @Published var event: Event? = nil
    @Published var error: String? = nil
    
    @Published var loadingSections = Set<Loadings>()
    
    init(idOrData: IdOrData<PlaceEssentials>, event: Event? = nil) {
        if let event {
            self.event = event
            self.place = event.place
        } else {
            switch idOrData {
            case .id(let placeId):
                Task { [weak self] in
                    self?.loadingSections.insert(.placeInfo)
                    do {
                        let placeOverview = try await self?.placeDM.getOverview(id: placeId)
                        if let placeOverview {
                            self?.place = PlaceEssentials(placeOverview: placeOverview)
                        }
                    } catch {
                        self?.error = getErrorMessage(error)
                    }
                    self?.loadingSections.remove(.placeInfo)
                }
                break
            case .data(let placeData):
                self.place = placeData
                break
            }
        }
    }
    
    init(mapPlace: MapPlace) {
        Task { [weak self] in
            self?.loadingSections.insert(.placeInfo)
            do {
                let placeData = try await self?.placeDM.fetch(mapPlace: mapPlace)
                if let placeData {
                    self?.place = PlaceEssentials(placeDetail: placeData)
                }
            } catch {
                self?.error = getErrorMessage(error)
            }
            self?.loadingSections.remove(.placeInfo)
        }
    }
    
    @MainActor
    func submit(mediaItems: [PickerMediaItem]) async {
        guard let place, !loadingSections.contains(.submitting) else { return }
        
        loadingSections.insert(.submitting)
        
        taskManager.newTask(.init(title: "New Checkin", mediaItems: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediaUsecase: .checkin, onReadyToSubmit: { mediaItems in
            let media: [UploadManager.MediaIds]? = if let mediaItems {
                UploadManager.getMediaIds(from: mediaItems)
            } else {
                nil
            }
            
            do {
                let body: CheckInDM.CheckinRequestBody = if let event = self.event {
                    .init(event: event.id, privacyType: self.privacyType, tags: self.mentions.compactMap({ $0.id }), caption: self.caption, media: media?.compactMap({ $0.uploadId }))
                } else {
                    .init(place: place.id, privacyType: self.privacyType, tags: self.mentions.compactMap({ $0.id }), caption: self.caption, media: media?.compactMap({ $0.uploadId }))
                }
                try await self.checkInDM.checkin(body: body)
                self.toastVM.toast(.init(type: .success, title: "Success", message: "Checked in"))
                self.place = nil
                HapticManager.shared.notification(type: .success)
            } catch {
                presentErrorToast(error)
            }
            
            self.loadingSections.remove(.submitting)
        }, onError: { error in
            presentErrorToast(error)
            self.loadingSections.remove(.submitting)
        }))
    }
    
    func updatePlaceLocationInfo() {
        Task {
            await place?.location.updateLocationInfo()
        }
    }
    
    enum Loadings: Hashable {
        case placeInfo
        case submitting
    }
    
    enum Sheets {
        case camera
        case photosPicker
        case userSelector
    }
}
