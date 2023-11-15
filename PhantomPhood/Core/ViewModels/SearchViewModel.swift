//
//  SearchViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/10/23.
//

import Foundation
import Combine
import MapKit

enum SearchScopes: String, CaseIterable, Identifiable {
    case places = "Places"
    case users = "Users"
    
    var id: String {
        self.rawValue
    }
}

enum SearchTokens: String, Identifiable {
    case checkin = "Checkin"
    case addReview = "Add Review"
    
    var id: String {
        self.rawValue
    }
}

enum SearchPlaceRegion {
    case nearMe
    case global
    
    var title: String {
        switch self {
        case .nearMe:
            "Near Me"
        case .global:
            "Global"
        }
    }
    
    var icon: String {
        switch self {
        case .nearMe:
            "location.fill"
        case .global:
            "globe"
        }
    }
//    case region: (CLLocationCoordinate2D)
}

@MainActor
class SearchViewModel: ObservableObject {
    private let apiManager = APIManager()
    private let auth = Authentication.shared
    private let locationManager = LocationManager.shared
    
    @Published var showSearch = false
    @Published var searchPlaceRegion: SearchPlaceRegion = .global
    @Published var text = ""
    @Published var scope: SearchScopes = .places
    @Published var tokens: [SearchTokens] = []
    
    @Published var placeSearchResults: [MKMapItem] = []
    @Published var userSearchResults: [User] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var cancellable = [AnyCancellable]()
    
    init() {
        if locationManager.location != nil {
            self.searchPlaceRegion = .nearMe
        }
        
        $text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { value in
                if value.isEmpty && self.scope == .users {
                    self.userSearchResults.removeAll()
                    return
                }
                self.search(value)

            }
            .store(in: &cancellable)
        
        $scope
            .sink { scope in
                self.search(self.text)
                
                if !self.tokens.isEmpty {
                    if scope != .places {
                        self.tokens.removeAll()
                    }
                }
            }
            .store(in: &cancellable)
        
        $searchPlaceRegion
            .sink { region in
                if region == .nearMe {
                    self.search(self.text)
                } else {
                    if !self.text.isEmpty {
                        self.search(self.text)
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    func search(_ value: String, region: MKCoordinateRegion? = nil) {
        self.isLoading = true

        if self.scope == .places {
            var theRegion: MKCoordinateRegion
            if let region {
                theRegion = region
            } else {
                theRegion = locationManager.region
            }
            
            let searchRequest = MKLocalSearch.Request()
            searchRequest.region = theRegion
            searchRequest.resultTypes = .pointOfInterest
            searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.cafe, .restaurant, .nightlife, .bakery, .brewery, .winery])
            searchRequest.naturalLanguageQuery = !value.isEmpty ? value : "cafe"
            
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { response, error in
                self.isLoading = false
                guard let response else { return }
                self.placeSearchResults = response.mapItems
            }
//            Task {
//                do {
//                    var locationQuery = ""
//                    if let location = locationManager.location {
//                        locationQuery += "&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&radius=\(self.searchPlaceRegion == .global ? "global" : String(2000))"
//                    }
//                    let data = try await self.apiManager.requestData("/places?limit=8\(value.isEmpty ? "" : "&q=\(value)")\(locationQuery)", token: self.auth.token) as PlaceSearchResponse?
//                    if let data {
//                        self.placeSearchResults = data.places
//                    }
//                    self.isLoading = false
//                } catch let error as APIManager.APIError {
//                    self.isLoading = false
//                    switch error {
//                    case .serverError(let serverError):
//                        self.error = serverError.message
//                        break
//                    default:
//                        self.error = "Unknown Error"
//                        break
//                    }
//                }
//            }
        } else if self.scope == .users {
            Task {
                do {
                    let data = try await self.apiManager.requestData("/users?q=\(value)", token: self.auth.token) as UserSearchResponse?
                    if let data {
                        self.userSearchResults = data.data
                    }
                    self.isLoading = false
                } catch let error as APIManager.APIError {
                    self.isLoading = false
                    switch error {
                    case .serverError(let serverError):
                        self.error = serverError.message
                        break
                    default:
                        self.error = "Unknown Error"
                        break
                    }
                }
            }
        }
    }
    
//    struct PlaceSearchResponse: Decodable {
//        let success: Bool
//        let places: [CompactPlace]
//    }
    struct UserSearchResponse: Decodable {
        let success: Bool
        let data: [User]
    }
}
