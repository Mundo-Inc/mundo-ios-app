//
//  QuickActionsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import Foundation
import MapKit

final class QuickActionsVM: LoadingSections, ObservableObject {
    private var searchDM = SearchDM()
    private var locationManager = LocationManager.shared
    
    @Published var nearestPlace: MKMapItem? = nil
    @Published var isNearestPlace = false
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @MainActor
    func handleCheckin() {
        if let nearestPlace, let name = nearestPlace.name, isNearestPlace {
            AppData.shared.goTo(AppRoute.checkinMapPlace(MapPlace(coordinate: nearestPlace.placemark.coordinate, title: name)))
        } else {
            SheetsManager.shared.presenting = .placeSelector(onSelect: { mapItem in
                if let name = mapItem.name {
                    AppData.shared.goTo(AppRoute.checkinMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                }
            })
        }
    }
    
    @MainActor
    func handleReview() {
        if let nearestPlace, let name = nearestPlace.name, isNearestPlace {
            AppData.shared.goTo(AppRoute.reviewMapPlace(MapPlace(coordinate: nearestPlace.placemark.coordinate, title: name)))
        } else {
            SheetsManager.shared.presenting = .placeSelector(onSelect: { mapItem in
                if let name = mapItem.name {
                    AppData.shared.goTo(AppRoute.reviewMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                }
            })
        }
    }
    
    func updateNearestPlace() async {
        guard let location = locationManager.location else { return }
        
        setLoadingState(.nearestPlace, to: true)
        do {
            let places = try await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100))
            
            if let first = places.first, first.name != nil {
                await MainActor.run {
                    self.nearestPlace = first
                    self.isNearestPlace = true
                }
            }
        } catch {
            presentErrorToast(error, silent: true)
        }
        setLoadingState(.nearestPlace, to: false)
    }
}

extension QuickActionsVM {
    enum LoadingSection: Hashable {
        case nearestPlace
    }
}
