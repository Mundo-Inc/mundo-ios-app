//
//  MapViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 19.09.2023.
//

import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
class MapViewModel: ObservableObject {
    private let dataManager = MapDataManager()
    private var cancellables: Set<AnyCancellable> = []
    private let regionSubject = PassthroughSubject<MKCoordinateRegion, Never>()
    
    @Published var places: [RegionPlace] = []
    @Published var isLoading = false

    
    init() {
        regionSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] region in
                Task {
                    await self?.fetchRegionPlaces(region: region)
                }
            }
            .store(in: &cancellables)
    }
    
//    var prevFetchRegion: MKCoordinateRegion? = nil
    
    func debouncedFetchRegionPlaces(region: MKCoordinateRegion) {
        regionSubject.send(region)
    }
    
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
