//
//  MapViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 19.09.2023.
//

import Foundation
import SwiftUI
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    let dataManager = PlaceDataManager()
    
    @Published var isLoading = false
    @Published var selectedPlaceData: Place? = nil
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    
    @available(iOS 17.0, *)
    func fetchPlace(mapFeature: MapFeature) async {
        self.selectedPlaceData = nil
        self.isLoading = true
        do {
            let data = try await dataManager.fetch(mapFeature: mapFeature)
            self.selectedPlaceData = data
        } catch(let err) {
            self.error = err.localizedDescription
        }
        self.isLoading = false
    }
    
    func fetchPlace(mapItem: MKMapItem) async {
        self.selectedPlaceData = nil
        self.isLoading = true
        do {
            let data = try await dataManager.fetch(mapItem: mapItem)
            self.selectedPlaceData = data
        } catch(let err) {
            self.error = err.localizedDescription
        }
        self.isLoading = false
    }
    
    
    func searchPointOfInterest(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        let searchRequest = MKLocalPointsOfInterestRequest(center: coordinate, radius: 50)
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let results = try await search.start()
            
            if let first = results.mapItems.first {
                return first
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func mapClickHandler(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        let mapItem = await searchPointOfInterest(coordinate: coordinate)
        
        return mapItem
    }
}
