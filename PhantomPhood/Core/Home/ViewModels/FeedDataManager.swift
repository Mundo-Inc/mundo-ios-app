//
//  FeedDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

class FeedDataManager {
    let apiManager = APIManager()
    private let auth: Authentication = Authentication.shared
    
    func getFeed(page: Int = 1) async throws -> [FeedItem] {
        struct FeedResponse: Decodable {
            let success: Bool
            let result: [FeedItem]
        }
        
        guard let token = await auth.token else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/feeds?page=\(page)", method: .get, token: token) as FeedResponse?
        if let data = data {
            return data.result
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getNabeel() async throws -> UserProfile {
        struct UserResponse: Decodable {
            let success: Bool
            let data: UserProfile
        }
        
        guard let token = await auth.token else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/645e7f843abeb74ee6248ced", method: .get, token: token) as UserResponse?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func followNabeel() async throws {
        struct FollowResponse: Decodable {
            let success: Bool
            let data: FollowData
            
            struct FollowData: Decodable {
                let user: String
                let target: String
            }
        }
        
        guard let token = await auth.token else {
            throw CancellationError()
        }
        
        let _ = try await apiManager.requestData("/users/645e7f843abeb74ee6248ced/connections", method: .post, token: token) as FollowResponse?
    }
}
