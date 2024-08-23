//
//  PlaceDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation
import SwiftUI
import MapKit

struct PlaceDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func fetch(mapPlace: MapPlace) async throws -> PlaceDetail {
        let token = try await auth.getToken()
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": mapPlace.title,
            "lat": String(mapPlace.coordinate.latitude),
            "lng": String(mapPlace.coordinate.longitude)
        ], token: token)
        
        return data.data
    }
    
    func fetch(mapItem: MKMapItem) async throws -> PlaceDetail {
        let token = try await auth.getToken()
        
        guard let title = mapItem.name else {
            throw URLError(.badServerResponse)
        }
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": title,
            "lat": String(mapItem.placemark.coordinate.latitude),
            "lng": String(mapItem.placemark.coordinate.longitude)
        ], token: token)
        
        return data.data
    }
    
    @available(iOS 17.0, *)
    func fetch(mapFeature: MapFeature) async throws -> PlaceDetail {
        let token = try await auth.getToken()
        
        guard let title = mapFeature.title else {
            throw URLError(.requestBodyStreamExhausted)
        }
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": title,
            "lat": String(mapFeature.coordinate.latitude),
            "lng": String(mapFeature.coordinate.longitude)
        ], token: token)
        
        return data.data
    }
    
    func fetch(id: String) async throws -> PlaceDetail {
        let token = try await auth.getToken()
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getOverview(id: String) async throws -> PlaceOverview {
        let token = try await auth.getToken()
        
        let data: APIResponse<PlaceOverview> = try await apiManager.requestData("/places/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getIncludedLists(id: String) async throws -> [String] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[String]> = try await apiManager.requestData("/places/\(id)/lists", token: token)
        
        return data.data
    }
    
    func getReviews(id: String, page: Int = 1, limit: Int = 1) async throws -> APIResponseWithPagination<[PlaceReview]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[PlaceReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func getGooglePlacesReviews(id: String) async throws -> [GoogleReview] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[GoogleReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "type": "googlePlaces"
        ], token: token)
        
        return data.data
    }
    
    func getYelpReviews(id: String) async throws -> [YelpReview] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[YelpReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "type": "yelp"
        ], token: token)
        
        return data.data
    }
    
    func getMedias(id: String, page: Int = 1, limit: Int = 30) async throws -> APIResponseWithPagination<[MediaItem]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/places/\(id)/media", queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
}
