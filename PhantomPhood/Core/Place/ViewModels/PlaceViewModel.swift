//
//  PlaceViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation
import MapKit

enum PlaceTab: String, CaseIterable, Hashable {
    case overview = "Overview"
    case reviews = "Reviews"
    case media = "Media"
}

@MainActor
class PlaceViewModel: ObservableObject {
    private let id: String
    
    private let dataManager = PlaceDataManager()
    
    @Published private(set) var isLoading = false
    @Published private(set) var place: Place?
    @Published private(set) var error: String?
    
    @Published var activeTab: PlaceTab = .overview
    @Published var prevActiveTab: PlaceTab = .overview
    
    init(id: String) {
        self.id = id
        
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        do {
            self.place = try await dataManager.fetch(id: id)
            self.error = nil
        } catch {
            print(error)
            self.error = error.localizedDescription
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
