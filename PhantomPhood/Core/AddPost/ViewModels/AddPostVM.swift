//
//  AddPostVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/26/24.
//

import Foundation

final class AddPostVM: ObservableObject, LoadingSections {
    private let placeDM = PlaceDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published private(set) var place: PlaceEssentials? = nil
    @Published private(set) var event: Event? = nil
    
    @Published var presentedSheet: Sheets? = nil
    @Published var savedImageId: String? = nil
    
    @Published private(set) var error: Error?
    
    init(event: Event) {
        self.event = event
        self.place = event.place
        
    }
    
    init(place: PlaceEssentials) {
        self.place = place
    }
    
    init(placeId: String) {
        Task { [weak self] in
            self?.setLoadingState(.fetchPlace, to: true)
            
            defer {
                self?.setLoadingState(.fetchPlace, to: false)
            }
            
            do {
                let placeOverview = try await self?.placeDM.getOverview(id: placeId)
                
                if let placeOverview {
                    self?.place = PlaceEssentials(placeOverview: placeOverview)
                }
            } catch {
                self?.error = error
            }
        }
    }
    
    init(mapPlace: MapPlace) {
        Task { [weak self] in
            self?.setLoadingState(.fetchPlace, to: true)
            
            defer {
                self?.setLoadingState(.fetchPlace, to: false)
            }
            
            do {
                let placeData = try await self?.placeDM.fetch(mapPlace: mapPlace)
                
                if let placeData {
                    self?.place = PlaceEssentials(placeDetail: placeData)
                }
            } catch {
                self?.error = error
            }
        }
    }
    
    func updatePlaceLocationInfo() {
        Task {
            await place?.location.updateLocationInfo()
        }
    }
    
    // MARK: Enums
    
    enum LoadingSection {
        case fetchPlace
    }
    
    enum Sheets {
        case camera
        case photosPicker
        case userSelector
    }
}
