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
    
    struct PlaceResponse: Decodable {
        let success: Bool
        let data: Place
    }
    
    func fetch(mapPlace: MapPlace) async throws -> Place {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
                
        let data = try await apiManager.requestData("/places/context?title=\(mapPlace.title)&lat=\(mapPlace.coordinate.latitude)&lng=\(mapPlace.coordinate.longitude)", method: .get, token: token) as PlaceResponse?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(mapItem: MKMapItem) async throws -> Place {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let title = mapItem.name else {
            throw URLError(.requestBodyStreamExhausted)
        }
        
        let data = try await apiManager.requestData("/places/context?title=\(title)&lat=\(mapItem.placemark.coordinate.latitude)&lng=\(mapItem.placemark.coordinate.longitude)", method: .get, token: token) as PlaceResponse?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    @available(iOS 17.0, *)
    func fetch(mapFeature: MapFeature) async throws -> Place {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let title = mapFeature.title else {
            throw URLError(.requestBodyStreamExhausted)
        }
        
//        645c1d1ab41f8e12a0d166bc
        let data = try await apiManager.requestData("/places/context?title=\(title)&lat=\(mapFeature.coordinate.latitude)&lng=\(mapFeature.coordinate.longitude)", method: .get, token: token) as PlaceResponse?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(id: String) async throws -> Place {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/places/\(id)", method: .get, token: token) as PlaceResponse?

        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func checkin(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct RequestBody: Encodable {
            let place: String
        }
        
        let body = try apiManager.createRequestBody(RequestBody(place: id))
        try await apiManager.requestNoContent("/checkins", method: .post, body: body, token: token)
    }
}
