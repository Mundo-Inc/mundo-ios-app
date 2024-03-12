//
//  PlaceDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation
import SwiftUI
import MapKit

final class PlaceDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func fetch(mapPlace: MapPlace) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/context?title=\(mapPlace.title)&lat=\(mapPlace.coordinate.latitude)&lng=\(mapPlace.coordinate.longitude)", method: .get, token: token) as APIResponse<PlaceDetail>?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(mapItem: MKMapItem) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let title = mapItem.name else {
            throw URLError(.requestBodyStreamExhausted)
        }
        
        let data = try await apiManager.requestData("/places/context?title=\(title)&lat=\(mapItem.placemark.coordinate.latitude)&lng=\(mapItem.placemark.coordinate.longitude)", method: .get, token: token) as APIResponse<PlaceDetail>?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    @available(iOS 17.0, *)
    func fetch(mapFeature: MapFeature) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let title = mapFeature.title else {
            throw URLError(.requestBodyStreamExhausted)
        }

        let data = try await apiManager.requestData("/places/context?title=\(title)&lat=\(mapFeature.coordinate.latitude)&lng=\(mapFeature.coordinate.longitude)", method: .get, token: token) as APIResponse<PlaceDetail>?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(id: String) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)", method: .get, token: token) as APIResponse<PlaceDetail>?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getOverview(id: String) async throws -> PlaceOverview {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)", method: .get, token: token) as APIResponse<PlaceOverview>?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getIncludedLists(id: String) async throws -> [String] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)/lists", token: token) as APIResponse<[String]>?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getReviews(id: String, page: Int = 1) async throws -> APIResponseWithPagination<[PlaceReview]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)/reviews?page=\(page)", token: token) as APIResponseWithPagination<[PlaceReview]>?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func getGooglePlacesReviews(id: String) async throws -> [GoogleReview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)/reviews?type=googlePlaces", token: token) as APIResponse<[GoogleReview]>?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getYelpReviews(id: String) async throws -> [YelpReview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)/reviews?type=yelp", token: token) as APIResponse<[YelpReview]>?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getMedias(id: String, page: Int = 1) async throws -> APIResponseWithPagination<[MediaWithUser]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)/media?page=\(page)", token: token) as APIResponseWithPagination<[MediaWithUser]>?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}
