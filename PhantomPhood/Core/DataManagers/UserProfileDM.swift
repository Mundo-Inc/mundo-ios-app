//
//  UserProfileDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class UserProfileDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func fetch(id: String) async throws -> UserProfile {
        struct UserResponse: Decodable {
            let success: Bool
            let data: UserProfile
        }
        
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/\(id)", method: .get, token: token) as UserResponse?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func follow(id: String) async throws {
        struct FollowResponse: Decodable {
            let success: Bool
            let data: FollowData
            
            struct FollowData: Decodable {
                let user: String
                let target: String
            }
        }
        
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let _ = try await apiManager.requestData("/users/\(id)/connections", method: .post, token: token) as FollowResponse?
    }
    
    func unfollow(id: String) async throws {
        struct FollowResponse: Decodable {
            let success: Bool
            let data: FollowData
            
            struct FollowData: Decodable {
                let user: String
                let target: String
            }
        }
        
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let _ = try await apiManager.requestNoContent("/users/\(id)/connections", method: .delete, token: token)
    }
    
    func block(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let _ = try await apiManager.requestNoContent("/users/\(id)/block", method: .post, token: token)
    }
    
    func unblock(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let _ = try await apiManager.requestNoContent("/users/\(id)/block", method: .delete, token: token)
    }
}
