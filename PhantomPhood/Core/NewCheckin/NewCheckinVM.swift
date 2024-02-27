//
//  NewCheckinVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/25/24.
//

import Foundation
import SwiftUI

@MainActor
final class NewCheckinVM: ObservableObject {
    private let toastVM = ToastVM.shared
    private let taskManager = TaskManager.shared
    private let placeDM = PlaceDM()
    
    @Published var privacyType: PrivacyType = .PUBLIC
    @Published var caption: String = ""
    @Published var mentions: [UserEssentials] = []
    
    @Published var presentedSheet: Sheets? = nil
    
    @Published var savedImageId: String? = nil
    
    @Published var isAdvancedSettingsVisible: Bool = false
    
    @Published var place: PlaceEssentials? = nil
    @Published var error: String? = nil
    
    @Published var loadingSections = Set<Loadings>()
    
    init(idOrData: IdOrData<PlaceEssentials>) {
        switch idOrData {
        case .id(let placeId):
            Task { [weak self] in
                self?.loadingSections.insert(.placeInfo)
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
                self?.loadingSections.remove(.placeInfo)
            }
            break
        case .data(let placeData):
            self.place = placeData
            break
        }
    }
    
    init(mapPlace: MapPlace) {
        Task { [weak self] in
            self?.loadingSections.insert(.placeInfo)
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
            self?.loadingSections.remove(.placeInfo)
        }
    }
    
    func submit(mediaItems: [MediaItem]) async {
        guard let place, !loadingSections.contains(.submitting) else { return }
        
        loadingSections.insert(.submitting)
        
        taskManager.newTask(.init(title: "New Checkin", medias: mediaItems.compactMap({ mediaItem in
            switch mediaItem.state {
            case .loaded(let mediaData):
                return TasksMedia.uncompressed(mediaItemData: .init(id: mediaItem.id, state: mediaData))
            default:
                return nil
            }
        }), mediasUsecase: .checkin, onReadyToSubmit: { medias in
            let image: UploadManager.MediaIds?
            if let medias, !medias.isEmpty {
                image = UploadManager.getMediaIds(from: medias, type: .image).first
            } else {
                image = nil
            }
            
            do {
                try await self.placeDM.checkin(body: .init(place: place.id, privacyType: self.privacyType, tags: self.mentions.compactMap({ user in
                    user.id
                }), caption: self.caption, image: image?.uploadId))
                self.toastVM.toast(.init(type: .success, title: "Success", message: "Checked in"))
                self.place = nil
                HapticManager.shared.notification(type: .success)
            } catch {
                print(error)
                self.toastVM.toast(.init(type: .error, title: "Error", message: "Couldn't check in"))
            }
            
            self.loadingSections.remove(.submitting)
        }, onError: { error in
            self.toastVM.toast(.init(type: .error, title: "Error", message: "Couldn't check in :("))
            self.loadingSections.remove(.submitting)
        }))
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
