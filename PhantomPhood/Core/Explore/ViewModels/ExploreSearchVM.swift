//
//  ExploreSearchVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import Foundation
import Combine
import MapKit

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
    @Published var userSearchResults: [User] = []
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
    
    func search(_ value: String, region: MKCoordinateRegion? = nil) async {
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
                let mapItems = try await searchDM.searchAppleMapsPlaces(region: theRegion, q: value)
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
