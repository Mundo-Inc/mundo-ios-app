//
//  FeedDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

final class FeedDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    enum FeedType: String {
        case followings
        case forYou
    }
    
    func getFeed(page: Int = 1, type: FeedType) async throws -> [FeedItem] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/feeds?page=\(page)\(type == .forYou ? "&isForYou=true" : "")", method: .get, token: token) as APIResponse<[FeedItem]>?
        
        if let data = data {
            return data.data
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getNabeel() async throws -> UserDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/645e7f843abeb74ee6248ced", method: .get, token: token) as APIResponse<UserDetail>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func followNabeel() async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/645e7f843abeb74ee6248ced/connections", method: .post, token: token)
    }
}
