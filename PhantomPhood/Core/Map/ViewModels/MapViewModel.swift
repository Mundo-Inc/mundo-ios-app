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
    private let placeDM = PlaceDataManager()
    private let mapDM = MapDM()
    
    @Published var isLoading = false
    @Published var selectedPlaceData: Place? = nil
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    
    private var firstMapActivityDataTime = Date()
    private(set) var mapActiviteis: [MapActivity] = []
    @Published private(set) var mapClusterActiviteis: Cluster.MapRegionCluster<MapActivity> = .init(clustered: [], solo: [])
    @Published private(set) var isActiviteisLoading = false
    /// For changing clusters on zoom change
    private var lastClusterRegion: MKCoordinateRegion? = nil
    
    @available(iOS 17.0, *)
    func fetchPlace(mapFeature: MapFeature) async {
        self.selectedPlaceData = nil
        self.isLoading = true
        do {
            let data = try await placeDM.fetch(mapFeature: mapFeature)
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
            let data = try await placeDM.fetch(mapItem: mapItem)
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
    
    func updateGeoActivities(for region: MKCoordinateRegion) async {
        guard !self.isActiviteisLoading else { return }
        
        self.isActiviteisLoading = true
        do {
            let data = try await self.mapDM.getGeoActivities(for: region)
            self.setMapActiviteis(activities: data, region: region)
        } catch {
            print(error)
        }
        self.isActiviteisLoading = false
    }
    
    private func setMapActiviteis(activities: [MapActivity], region: MKCoordinateRegion) {
        if abs(self.firstMapActivityDataTime.timeIntervalSinceNow) > 90 {
            self.mapActiviteis.removeAll()
            self.firstMapActivityDataTime = Date()
        }
        
        self.mapActiviteis.append(contentsOf: activities.filter({ mapActivity in
            !self.mapActiviteis.contains { prevMapActivity in
                prevMapActivity.id == mapActivity.id
            }
        }))

        updateClusters(region: region, force: true)
    }
    
    func updateClusters(region: MKCoordinateRegion, force: Bool = false) {
        if let lastClusterRegion {
            let delta = min(abs(region.span.longitudeDelta), abs(region.span.latitudeDelta))
            let lastDelta = min(abs(lastClusterRegion.span.longitudeDelta), abs(lastClusterRegion.span.latitudeDelta))
            
            if delta > lastDelta ? 1.0 - (lastDelta / delta) >= 0.3 : 1.0 - (delta / lastDelta) >= 0.3 {
                self.mapClusterActiviteis = Cluster.getMapRegionCluster(region: region, items: self.mapActiviteis)
                self.lastClusterRegion = region
            } else if force {
                self.mapClusterActiviteis = Cluster.getMapRegionCluster(region: lastClusterRegion, items: self.mapActiviteis)
            }
        } else {
            self.mapClusterActiviteis = Cluster.getMapRegionCluster(region: region, items: self.mapActiviteis)
            self.lastClusterRegion = region
        }
    }
}
