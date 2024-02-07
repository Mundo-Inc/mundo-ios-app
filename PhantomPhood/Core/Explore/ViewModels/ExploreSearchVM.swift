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
            return Image(systemName: "fork.knife")
        case .coffee:
            return Image(systemName: "cup.and.saucer")
        case .bars:
            return Image(systemName: "wineglass")
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
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        switch self {
        case .places:
            "Places"
        case .users:
            "Users"
        }
    }
}

@MainActor
final class ExploreSearchVM: ObservableObject {
    private let locationManager = LocationManager.shared
    private let searchDM = SearchDM()
    
    var mapRegion: MKCoordinateRegion? = nil
    
    @Published var text = ""
    @Published var scope: SearchScopes = .places
    
    @Published var placeSearchResults: [MKMapItem] = []
    @Published var userSearchResults: [UserEssentials] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var cancellable = [AnyCancellable]()
    
    init() {
        $text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
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
        self.isLoading = true

        if self.scope == .places {
            var theRegion: MKCoordinateRegion
            if let region {
                theRegion = region
            } else if let mapRegion {
                theRegion = mapRegion
            } else {
                theRegion = locationManager.region
            }
            do {
                let mapItems = try await searchDM.searchAppleMapsPlaces(region: theRegion, q: value, categories: categories)
                self.placeSearchResults = mapItems
            } catch {
                print(error)
            }
        } else if self.scope == .users {
            do {
                let data = try await searchDM.searchUsers(q: value)
                self.userSearchResults = data
            } catch let error as APIManager.APIError {
                switch error {
                case .serverError(let serverError):
                    self.error = serverError.message
                    break
                default:
                    self.error = "Unknown Error"
                    break
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
        
        self.isLoading = false
    }
}
