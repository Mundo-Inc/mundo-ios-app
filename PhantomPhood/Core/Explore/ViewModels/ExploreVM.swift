//
//  ExploreVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import Foundation
import SwiftUI
import MapKit

@available(iOS 17.0, *)
@MainActor
final class ExploreVM17: ObservableObject {
    
    // MARK: - Shared
    
    @Published var selectedPlaceData: PlaceDetail? = nil
    
    private let placeDM = PlaceDM()
    private let mapDM = MapDM()
    private let searchDM = SearchDM()
    
    @Published private(set) var isLoading = false
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    
    @Published private(set) var mapClusterActivities: MapActivityClusters = .init(clustered: [], solo: [])
    @Published private(set) var isActiviteisLoading = false
    
    private var firstMapActivityDataTime = Date()
    private var mapActiviteis: [MapActivity] = []
    /// For changing clusters on zoom change
    private var lastClusterRegion: MKCoordinateRegion? = nil
    
    // MARK: - Exclusive
    
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var selection: MapFeature? = nil
    
    @Published var selectedMapItem: MKMapItem? = nil
    
    @Published var throttle = Throttle(interval: 2)
    
    @Published var selectedMapActivity: MapActivity? = nil
    
    @Published var scale: CGFloat = 1
    
    init() {
        if let region = MapCameraPosition.userLocation(fallback: .automatic).region {
            Task {
                await self.updateGeoActivities(for: region)
            }
        }
    }
    
    // MARK: - Shared Methods
    
    func setSearchResults(_ searchResults: [MKMapItem]) {
        self.searchResults = searchResults
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
    
    func mapClickHandler(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        do {
            let mapItems = try await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: coordinate, latitudinalMeters: 50, longitudinalMeters: 50))
            
            if let first = mapItems.first {
                return first
            } else {
                return nil
            }
        } catch {
            return nil
        }
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
    
    func updateClusters(region: MKCoordinateRegion, force: Bool = false) {
        if let lastClusterRegion {
            let delta = min(abs(region.span.longitudeDelta), abs(region.span.latitudeDelta))
            let lastDelta = min(abs(lastClusterRegion.span.longitudeDelta), abs(lastClusterRegion.span.latitudeDelta))
            
            if delta > lastDelta ? 1.0 - (lastDelta / delta) >= 0.3 : 1.0 - (delta / lastDelta) >= 0.3 {
                self.mapClusterActivities = MapActivityClusters(region: region, items: self.mapActiviteis)
                self.lastClusterRegion = region
            } else if force {
                self.mapClusterActivities = MapActivityClusters(region: lastClusterRegion, items: self.mapActiviteis)
            }
        } else {
            self.mapClusterActivities = MapActivityClusters(region: region, items: self.mapActiviteis)
            self.lastClusterRegion = region
        }
    }
    
    // MARK: - Private Shared Methods
    
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
    
    // MARK: - Exlusive Methods
    
    func fetchPlace(mapFeature: MapFeature) async {
        self.selectedPlaceData = nil
        self.isLoading = true
        do {
            let data = try await placeDM.fetch(mapFeature: mapFeature)
            self.selectedPlaceData = data
        } catch(let err) {
            print("Error", err)
            self.error = err.localizedDescription
        }
        self.isLoading = false
    }

    func panToRegion(_ region: MKCoordinateRegion) {
        position = .region(region)
    }
}

@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use ExploreVM17 for iOS 17 and above")
@MainActor
final class ExploreVM16: ObservableObject {
    
    // MARK: - Shared
    
    @Published var selectedPlaceData: PlaceDetail? = nil
    
    private let placeDM = PlaceDM()
    private let mapDM = MapDM()
    private let searchDM = SearchDM()
    
    @Published private(set) var isLoading = false
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    
    @Published private(set) var mapClusterActivities: MapActivityClusters = .init(clustered: [], solo: [])
    @Published private(set) var isActiviteisLoading = false
    
    private var firstMapActivityDataTime = Date()
    private var mapActiviteis: [MapActivity] = []
    /// For changing clusters on zoom change
    private var lastClusterRegion: MKCoordinateRegion? = nil
    
    // MARK: - Exclusive
    
    private var locationManager = LocationManager.shared
    
    @Published var selectedPlace: MKMapItem? = nil
    @Published var centerCoordinate = CLLocationCoordinate2D()
    
    init() {
        if let location = locationManager.location {
            self.centerCoordinate = location.coordinate
        }
    }
    
    // MARK: - Shared Methods
    
    func setSearchResults(_ searchResults: [MKMapItem]) {
        self.searchResults = searchResults
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
    
    func mapClickHandler(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        do {
            let mapItems = try await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: coordinate, latitudinalMeters: 50, longitudinalMeters: 50))
            
            if let first = mapItems.first {
                return first
            } else {
                return nil
            }
        } catch {
            return nil
        }
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
    
    func updateClusters(region: MKCoordinateRegion, force: Bool = false) {
        if let lastClusterRegion {
            let delta = min(abs(region.span.longitudeDelta), abs(region.span.latitudeDelta))
            let lastDelta = min(abs(lastClusterRegion.span.longitudeDelta), abs(lastClusterRegion.span.latitudeDelta))
            
            if delta > lastDelta ? 1.0 - (lastDelta / delta) >= 0.3 : 1.0 - (delta / lastDelta) >= 0.3 {
                self.mapClusterActivities = MapActivityClusters(region: region, items: self.mapActiviteis)
                self.lastClusterRegion = region
            } else if force {
                self.mapClusterActivities = MapActivityClusters(region: lastClusterRegion, items: self.mapActiviteis)
            }
        } else {
            self.mapClusterActivities = MapActivityClusters(region: region, items: self.mapActiviteis)
            self.lastClusterRegion = region
        }
    }
    
    // MARK: - Private Shared Methods
    
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
    
    // MARK: - Exlusive Methods
    
    func panToRegion(_ region: MKCoordinateRegion) {
        self.centerCoordinate = region.center
    }
}
