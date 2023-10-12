//
//  MapViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 19.09.2023.
//

import Foundation
import SwiftUI
import MapKit

@available(iOS 17.0, *)
@MainActor
class MapViewModel: ObservableObject {
    private let dataManager = MapDataManager()
    
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @Published var places: [RegionPlace] = []
    @Published var isLoading = false
    
//    var prevFetchRegion: MKCoordinateRegion? = nil
    
    func fetchRegionPlaces(region: MKCoordinateRegion) async {
        let NElat = region.center.latitude + (region.span.latitudeDelta / 2)
        let NElng = region.center.longitude + (region.span.longitudeDelta / 2)
        let SWlat = region.center.latitude - (region.span.latitudeDelta / 2)
        let SWlng = region.center.longitude - (region.span.longitudeDelta / 2)
        
//        if let PRegion = prevFetchRegion {
//            guard !isAlmostSameRegion(region1: region, region2: PRegion, threshold: 0.1) else {
//                return
//            }
//        }
        
//        prevFetchRegion = region
        
        self.isLoading = true
        do {
            self.places = try await dataManager.fetchRegionPlaces(NElat: NElat, NElng: NElng, SWlat: SWlat, SWlng: SWlng)
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
//    private func isAlmostSameRegion(region1: MKCoordinateRegion, region2: MKCoordinateRegion, threshold: Double) -> Bool {
//        let centerDiffLat = abs(region1.center.latitude - region2.center.latitude)
//        let centerDiffLng = abs(region1.center.longitude - region2.center.longitude)
//        
//        if centerDiffLat > threshold || centerDiffLng > threshold {
//            return false
//        }
//        
//        // Check difference between spans
//        let spanDiffLat = abs(region1.span.latitudeDelta - region2.span.latitudeDelta)
//        let spanDiffLng = abs(region1.span.longitudeDelta - region2.span.longitudeDelta)
//        
//        if spanDiffLat > threshold || spanDiffLng > threshold {
//            return false
//        }
//        
//        return true
//    }
}
