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
    
    @Published var nearestPlace: MKMapItem? = nil
    @Published var isNearestPlace = false
    
    @Published var loadingSections = Set<Sections>()
    
    func handleCheckin() {
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
    
    func handleReview() {
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
