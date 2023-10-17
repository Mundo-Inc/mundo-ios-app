//
//  SearchViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/10/23.
//

import Foundation
import Combine

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
    
    @Published var placeSearchResults: [CompactPlace] = []
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
    
    func search(_ value: String) {
        self.isLoading = true

        if self.scope == .places {
            Task {
                do {
                    var locationQuery = ""
                    if let location = locationManager.location {
                        locationQuery += "&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&radius=\(self.searchPlaceRegion == .global ? "global" : String(2000))"
                    }
                    let (data, _) = try await self.apiManager.request("/places?limit=8\(value.isEmpty ? "" : "&q=\(value)")\(locationQuery)", token: self.auth.token) as (PlaceSearchResponse?, HTTPURLResponse)
                    if let data {
                        self.placeSearchResults = data.places
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
        } else if self.scope == .users {
            Task {
                do {
                    let (data, _) = try await self.apiManager.request("/users?q=\(value)", token: self.auth.token) as (UserSearchResponse?, HTTPURLResponse)
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
    
    struct PlaceSearchResponse: Decodable {
        let success: Bool
        let places: [CompactPlace]
    }
    struct UserSearchResponse: Decodable {
        let success: Bool
        let data: [User]
    }
}
