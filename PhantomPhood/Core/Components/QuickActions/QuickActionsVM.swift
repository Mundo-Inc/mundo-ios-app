//
//  QuickActionsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import Foundation
import MapKit

@MainActor
final class QuickActionsVM: ObservableObject {
    private var placeSelectorVM = PlaceSelectorVM.shared
    private var appData = AppData.shared
    private var searchDM = SearchDM()
    private var locationManager = LocationManager.shared
    
    enum Sections: Hashable {
        case nearestPlace
    }
    
    init() {
        updateIsViewingPlace()
    }
    
    @Published var nearestPlace: MKMapItem? = nil
    @Published var isNearestPlace = false
    
    @Published var isViewingPlace = false
    @Published var loadingSections = Set<Sections>()
    
    func handleCheckin() {
        if isViewingPlace {
            switch appData.getActiveRotue() {
            case .place(let id, _):
                appData.goTo(AppRoute.checkin(.id(id)))
            case .placeMapPlace(let mapPlace, _):
                appData.goTo(AppRoute.checkinMapPlace(mapPlace))
            default:
                break
            }
        } else {
            if let nearestPlace, let name = nearestPlace.name, isNearestPlace {
                appData.goTo(AppRoute.checkinMapPlace(MapPlace(coordinate: nearestPlace.placemark.coordinate, title: name)))
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.placeSelectorVM.present { mapItem in
                        if let name = mapItem.name {
                            self.appData.goTo(AppRoute.checkinMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                        }
                    }
                }
            }
        }
    }
    
    func handleReview() {
        if isViewingPlace {
            switch appData.getActiveRotue() {
            case .place(let id, _):
                appData.goTo(AppRoute.review(.id(id)))
            case .placeMapPlace(let mapPlace, _):
                appData.goTo(AppRoute.reviewMapPlace(mapPlace))
            default:
                break
            }
        } else {
            if let nearestPlace, let name = nearestPlace.name, isNearestPlace {
                appData.goTo(AppRoute.reviewMapPlace(MapPlace(coordinate: nearestPlace.placemark.coordinate, title: name)))
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.placeSelectorVM.present { mapItem in
                        if let name = mapItem.name {
                            self.appData.goTo(AppRoute.reviewMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                        }
                    }
                }
            }
        }
    }
    
    func updateIsViewingPlace() {
        switch appData.getActiveRotue() {
        case .place(_, _), .placeMapPlace(_, _):
            self.isViewingPlace = true
        default:
            self.isViewingPlace = false
            
            // search for nearest place
            Task {
                loadingSections.insert(.nearestPlace)
                do {
                    let places = try await searchDM.searchAppleMapsPlaces(region: locationManager.region)
                    if let first = places.first, first.name != nil {
                        self.nearestPlace = first
                        self.isNearestPlace = true
                    }
                } catch {
                    print(error)
                }
                loadingSections.remove(.nearestPlace)
            }
            
        }
    }
}
