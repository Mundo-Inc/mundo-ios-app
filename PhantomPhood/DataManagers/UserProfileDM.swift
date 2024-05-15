//
//  UserProfileDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation
import CoreData

final class UserProfileDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    private let dataManager = DataStack.shared
    
    /// No authentication needed
    func getUserEssentials(id: String) async throws -> UserEssentials {
        let data: APIResponse<UserEssentials> = try await apiManager.requestData("/users/\(id)?view=basic", method: .get)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: data.data)
        
        return data.data
    }
    
    func getUserEssentialsAndUpdate(id: String, returnIfFound: Bool = false, coreDataCompletion: @escaping (UserEssentials) -> Void) async throws -> UserEssentials? {
        do {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            if let user = try dataManager.viewContext.fetch(request).first,
               let userEssentials = try? UserEssentials(entity: user),
               let savedAt = user.savedAt {
                if Date().timeIntervalSince(savedAt) < 60 * 60 * 24 {
                    coreDataCompletion(userEssentials)
                    if returnIfFound {
                        return nil
                    }
                }
            }
        } catch {
            presentErrorToast(error, debug: "Error getting user infor from CoreData", silent: true)
        }
        
        let data: APIResponse<UserEssentials> = try await apiManager.requestData("/users/\(id)?view=basic", method: .get)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: data.data)
        
        return data.data
    }
    
    func fetch(id: String) async throws -> UserDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<UserDetail> = try await apiManager.requestData("/users/\(id)", method: .get, token: token)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: UserEssentials(userDetail: data.data))
        
        return data.data
    }
    
    func fetch(username: String) async throws -> UserDetail {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<UserDetail> = try await apiManager.requestData("/users/@\(username)", method: .get, token: token)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: UserEssentials(userDetail: data.data))
        
        return data.data
    }
    
    func getFollowRequests(page: Int = 1, limit: Int = 30) async throws -> APIResponseWithPagination<[FollowRequest]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[FollowRequest]> = try await apiManager.requestData("/users/followRequests?page=\(page)&limit=\(limit)", method: .get, token: token)
        
        return data
    }
    
    func follow(id: String) async throws -> FollowRequestStatus {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let httpResponse = try await apiManager.requestNoContent("/users/\(id)/connections", method: .post, token: token)
        
        if httpResponse.statusCode == 201 {
            return .following
        } else if httpResponse.statusCode == 202 {
            return .requested
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func unfollow(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(id)/connections", method: .delete, token: token)
    }
    
    func removeFollower(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/followers/\(id)", method: .delete, token: token)
    }
    
    func acceptRequest(for requestId: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/followRequests/\(requestId)", method: .post, token: token)
    }
    
    func rejectRequest(for requestId: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/followRequests/\(requestId)", method: .delete, token: token)
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
    
    @discardableResult
    func getReferredUsers() async throws -> APIResponseWithPagination<[UserEssentialsWithCreationDate]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[UserEssentialsWithCreationDate]> = try await apiManager.requestData("/users/latestReferrals", method: .get, token: token)
        
        UserDataStack.shared.saveUsers(userEssentialsList: data.data)
        
        return data
    }
    
    // MARK: - Response Models
    
    struct UserEssentialsWithCreationDate: Identifiable, Decodable {
        let id: String
        let name: String
        let username: String
        let verified: Bool
        let isPrivate: Bool
        let profileImage: URL?
        let progress: UserEssentials.CompactUserProgress
        let createdAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, username, verified, isPrivate, profileImage, progress, createdAt
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            username = try container.decode(String.self, forKey: .username)
            verified = try container.decode(Bool.self, forKey: .verified)
            isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
            progress = try container.decode(UserEssentials.CompactUserProgress.self, forKey: .progress)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            profileImage = try container.decodeURLIfPresent(forKey: .profileImage)
        }
    }
    
    // MARK: Enums
    
    enum FollowRequestStatus {
        case following
        case requested
    }
}
