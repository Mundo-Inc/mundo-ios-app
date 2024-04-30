//
//  ExploreSearchVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import Foundation
import Combine
import MapKit
import SwiftUI

enum MapDefaultSearch: String, CaseIterable {
    case restaurants
    case coffee
    case bars
    case takeout
    case delivery
    
    var title: String {
        switch self {
        case .restaurants:
            return "Restaurants"
        case .coffee:
            return "Coffee"
        case .bars:
            return "Bars"
        case .takeout:
            return "Takeout"
        case .delivery:
            return "Delivery"
        }
    }
    
    var categories: [MKPointOfInterestCategory] {
        switch self {
        case .restaurants:
            return [.restaurant]
        case .coffee:
            return [.cafe]
        case .bars:
            return [.nightlife]
        case .takeout:
            return [.restaurant, .cafe]
        case .delivery:
            return [.restaurant, .cafe]
        }
    }
    
    var search: String {
        switch self {
        case .restaurants:
            return "Restaurant"
        case .coffee:
            return "Coffee"
        case .bars:
            return "Bar"
        case .takeout:
            return "Takeout"
        case .delivery:
            return "Delivery"
        }
    }
    
    var image: Image {
        switch self {
        case .restaurants:
            return MKPointOfInterestCategory.restaurant.image
        case .coffee:
            return MKPointOfInterestCategory.cafe.image
        case .bars:
            return MKPointOfInterestCategory.nightlife.image
        case .takeout:
            return Image(systemName: "takeoutbag.and.cup.and.straw")
        case .delivery:
            return Image(systemName: "suitcase.cart")
        }
    }
}

enum SearchScopes: String, CaseIterable, Identifiable {
    case places
    case users
    case events
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        switch self {
        case .places:
            "Places"
        case .users:
            "Users"
        case .events:
            "Events"
        }
    }
}

@MainActor
final class ExploreSearchVM: ObservableObject {
    private let locationManager = LocationManager.shared
    private let searchDM = SearchDM()
    private let eventsDM = EventsDM()
    
    var mapRegion: MKCoordinateRegion? = nil
    
    @Published var text = ""
    @Published var scope: SearchScopes = .places
    
    @Published var placeSearchResults: [MKMapItem] = []
    @Published var userSearchResults: [UserEssentials] = []
    @Published var eventsSearchResult: [Event] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var queueSearch: (() async -> Void)?
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $text
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .sink { value in
                Task {
                    await self.search(self.text)
                }
            }
            .store(in: &cancellable)
        
        $scope
            .sink { scope in
                Task {
                    await self.search(self.text)
                }
            }
            .store(in: &cancellable)
    }
    
    func search(_ value: String, region: MKCoordinateRegion? = nil, categories: [MKPointOfInterestCategory]? = nil) async {
        guard !isLoading else {
            self.queueSearch = {
                await self.search(value, region: region, categories: categories)
            }
            return
        }
        
        self.isLoading = true
        
        switch self.scope {
        case .places:
            let theRegion = region ?? mapRegion ?? (locationManager.location != nil ? MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 800, longitudinalMeters: 800) : MKCoordinateRegion())
            
            do {
                self.placeSearchResults = try await searchDM.searchAppleMapsPlaces(region: theRegion, q: value, categories: categories)
            } catch {
                presentErrorToast(error, silent: true)
            }
        case .users:
            do {
                self.userSearchResults = try await searchDM.searchUsers(q: value)
            } catch {
                presentErrorToast(error)
            }
        case .events:
            do {
                self.eventsSearchResult = try await eventsDM.getEvents(q: value)
            } catch {
                presentErrorToast(error)
            }
        }
        
        self.isLoading = false
        
        if let queueSearch = self.queueSearch {
            self.queueSearch = nil
            await queueSearch()
        }
    }
}
