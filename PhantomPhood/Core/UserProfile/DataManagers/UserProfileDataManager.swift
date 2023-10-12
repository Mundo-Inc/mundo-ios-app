//
//  UserProfileDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class UserProfileDataManager {
    private let apiManager = APIManager()
    private let auth: Authentication = Authentication.shared
    
    func fetch(id: String) async throws -> UserProfile {
        struct UserResponse: Decodable {
            let success: Bool
            let data: UserProfile
        }
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        let (data, _) = try await apiManager.request("/users/\(id)", method: .get, token: token) as (UserResponse?, HTTPURLResponse)
        
        guard let data = data else {
            fatalError("Couldn't get the data")
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
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        let _ = try await apiManager.request("/users/\(id)/connections", method: .post, token: token) as (FollowResponse?, HTTPURLResponse)
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
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        let _ = try await apiManager.requestNoContent("/users/\(id)/connections", method: .delete, token: token)
    }
}
