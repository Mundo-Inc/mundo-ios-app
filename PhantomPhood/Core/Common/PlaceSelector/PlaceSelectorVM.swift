//
//  PlaceSelectorVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import Foundation
import Combine
import MapKit

enum SearchTokens: String, Identifiable {
    case checkin = "Check In"
    case addReview = "Add Review"
    
    var id: String {
        self.rawValue
    }
}

@MainActor
final class PlaceSelectorVM: ObservableObject {
    static let shared = PlaceSelectorVM()
    
    private let locationManager = LocationManager.shared
    private let searchDM = SearchDM()

    var onSelect: ((MKMapItem) -> Void)? = nil

    var mapRegion: MKCoordinateRegion? = nil
    
    @Published var results: [MKMapItem] = []
    
    @Published var isPresented = false
    @Published var text = ""
    @Published var tokens: [SearchTokens] = []
    
    @Published var isLoading: Bool = false
    
    private var cancellable = [AnyCancellable]()
    
    init() {
        $isPresented
            .sink { value in
                if !value {
                    self.results.removeAll()
                    self.text = ""
                }
            }
            .store(in: &cancellable)
        
        $text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { value in
                Task {
                    await self.search(value)
                }
            }
            .store(in: &cancellable)
    }

    func present(onSelect: @escaping (MKMapItem) -> Void) {
        self.onSelect = onSelect
        self.isPresented = true
    }
    
    private func search(_ value: String) async {
        self.isLoading = true
        
        var theRegion: MKCoordinateRegion
        if let mapRegion {
            theRegion = mapRegion
        } else if let location = locationManager.location {
            theRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        } else {
            theRegion = MKCoordinateRegion()
        }
        
        do {
            let mapItems = try await searchDM.searchAppleMapsPlaces(region: theRegion, q: value.isEmpty ? nil : value)
            self.results = mapItems
        } catch {
            print(error)
        }
        
        self.isLoading = false
    }
}
