//
//  PlaceSelectorVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import Foundation
import Combine
import MapKit

@MainActor
final class PlaceSelectorVM: ObservableObject {
    private let locationManager = LocationManager.shared
    private let searchDM = SearchDM()

    var mapRegion: MKCoordinateRegion? = nil
    
    @Published private(set) var results: [MKMapItem] = []
    
    @Published var text = ""
    
    @Published var isLoading: Bool = false
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                Task {
                    await self?.search(value)
                }
            }
            .store(in: &cancellable)
    }

    private func search(_ value: String) async {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        let theRegion = mapRegion ?? (locationManager.location != nil ? MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 800, longitudinalMeters: 800) : MKCoordinateRegion())
        
        do {
            self.results = try await searchDM.searchAppleMapsPlaces(region: theRegion, q: value.isEmpty ? nil : value)
        } catch {
            presentErrorToast(error, silent: true)
        }
    }
}
