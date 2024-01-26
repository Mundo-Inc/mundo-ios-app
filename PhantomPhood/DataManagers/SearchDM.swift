//
//  SearchDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import Foundation
import MapKit

final class SearchDM {
    static let AcceptablePointOfInterestCategories: [MKPointOfInterestCategory] = [.cafe, .restaurant, .nightlife, .bakery, .brewery, .winery]
    
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    // MARK: - Public methods
    
    func searchUsers(q: String) async throws -> [UserOverview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let resData = try await apiManager.requestData("/users\(q.isEmpty ? "" : "?q=\(q)")", token: token) as APIResponse<[UserOverview]>?
        
        guard let resData else {
            throw URLError(.badServerResponse)
        }
        
        return resData.data
    }
    
    func searchAppleMapsPlaces(region: MKCoordinateRegion, q: String? = nil, categories: [MKPointOfInterestCategory]? = nil) async throws -> [MKMapItem] {
        if let q, !q.isEmpty {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.region = region
            searchRequest.resultTypes = .pointOfInterest
            if let categories {
                searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)
            } else {
                searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: SearchDM.AcceptablePointOfInterestCategories)
            }
            searchRequest.naturalLanguageQuery = q
            
            let search = MKLocalSearch(request: searchRequest)
            let response = try await search.start()
            return response.mapItems
        } else {
            let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: SearchDM.AcceptablePointOfInterestCategories)
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems
        }
    }
}
