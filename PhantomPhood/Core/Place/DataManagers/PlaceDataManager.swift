//
//  PlaceDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation

class PlaceDataManager {
    private let apiManager = APIManager()
    private let auth: Authentication = Authentication.shared
    
    func fetch(id: String) async throws -> Place {
        struct PlaceResponse: Decodable {
            let success: Bool
            let data: Place
        }
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        let (data, _) = try await apiManager.request("/places/\(id)", method: .get, token: token) as (PlaceResponse?, HTTPURLResponse)

        guard let data = data else {
            fatalError("Couldn't get the data")
        }
        
        return data.data
    }
    
    func checkin(id: String) async throws {
        struct CheckinResponse: Decodable {
            let success: Bool
            let data: CheckinData
            
            struct CheckinData: Decodable {
                let user: String
                let place: String
            }
        }
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        struct RequestBody: Encodable {
            let place: String
        }
        
        let body = try apiManager.createRequestBody(RequestBody(place: id))
        
        let _ = try await apiManager.request("/checkins", method: .post, body: body, token: token) as (CheckinResponse?, HTTPURLResponse)
    }
}
