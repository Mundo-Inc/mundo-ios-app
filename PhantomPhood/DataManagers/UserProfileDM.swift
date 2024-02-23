//
//  UserProfileDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

final class UserProfileDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    /// No authentication needed
    func getUserEssentials(id: String) async throws -> UserEssentials {
        let data = try await apiManager.requestData("/users/\(id)?view=basic", method: .get) as APIResponse<UserEssentials>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(id: String) async throws -> UserDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/\(id)", method: .get, token: token) as APIResponse<UserDetail>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func fetch(username: String) async throws -> UserDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/@\(username)", method: .get, token: token) as APIResponse<UserDetail>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func follow(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(id)/connections", method: .post, token: token)
    }
    
    func unfollow(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(id)/connections", method: .delete, token: token)
    }
    
    func block(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(id)/block", method: .post, token: token)
    }
    
    func unblock(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(id)/block", method: .delete, token: token)
    }
    
    func getReferredUsers() async throws -> APIResponseWithPagination<[UserEssentialsWithCreationDate]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/latestReferrals", method: .get, token: token) as APIResponseWithPagination<[UserEssentialsWithCreationDate]>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    // MARK: - Response Models
    
    struct UserEssentialsWithCreationDate: Identifiable, Decodable {
        let id: String
        let name: String
        let username: String
        let verified: Bool
        let profileImage: URL?
        let progress: UserEssentials.CompactUserProgress
        let createdAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, username, verified, profileImage, progress, createdAt
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            username = try container.decode(String.self, forKey: .username)
            verified = try container.decode(Bool.self, forKey: .verified)
            progress = try container.decode(UserEssentials.CompactUserProgress.self, forKey: .progress)
            createdAt = try container.decode(Date.self, forKey: .createdAt)

            if let profileImageString = try container.decodeIfPresent(String.self, forKey: .profileImage), !profileImageString.isEmpty {
                profileImage = URL(string: profileImageString)
            } else {
                profileImage = nil
            }
        }
    }
}
