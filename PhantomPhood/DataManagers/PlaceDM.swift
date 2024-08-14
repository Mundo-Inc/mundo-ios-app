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
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": mapPlace.title,
            "lat": mapPlace.coordinate.latitude.description,
            "lng": mapPlace.coordinate.longitude.description
        ], token: token)
        
        return data.data
    }
    
    func fetch(mapItem: MKMapItem) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let title = mapItem.name else {
            throw URLError(.requestBodyStreamExhausted)
        }
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": title,
            "lat": mapItem.placemark.coordinate.latitude.description,
            "lng": mapItem.placemark.coordinate.longitude.description
        ], token: token)
        
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
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/context", method: .get, queryParams: [
            "title": title,
            "lat": mapFeature.coordinate.latitude.description,
            "lng": mapFeature.coordinate.longitude.description
        ], token: token)
        
        return data.data
    }
    
    func fetch(id: String) async throws -> PlaceDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<PlaceDetail> = try await apiManager.requestData("/places/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getOverview(id: String) async throws -> PlaceOverview {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<PlaceOverview> = try await apiManager.requestData("/places/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getIncludedLists(id: String) async throws -> [String] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[String]> = try await apiManager.requestData("/places/\(id)/lists", token: token)
        
        return data.data
    }
    
    func getReviews(id: String, page: Int = 1, limit: Int = 1) async throws -> APIResponseWithPagination<[PlaceReview]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[PlaceReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
    
    func getGooglePlacesReviews(id: String) async throws -> [GoogleReview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[GoogleReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "type": "googlePlaces"
        ], token: token)
        
        return data.data
    }
    
    func getYelpReviews(id: String) async throws -> [YelpReview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[YelpReview]> = try await apiManager.requestData("/places/\(id)/reviews", queryParams: [
            "type": "yelp"
        ], token: token)
        
        return data.data
    }
    
    func getMedias(id: String, page: Int = 1, limit: Int = 1) async throws -> APIResponseWithPagination<[MediaItem]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/places/\(id)/media", queryParams: [
            "page": page.description,
            "limit": limit.description,
        ], token: token)
        
        return data
    }
}
