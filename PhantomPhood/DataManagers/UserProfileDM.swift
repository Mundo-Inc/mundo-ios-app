//
//  UserProfileDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct UserProfileDM {
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
    
    func getUserEssentialsAndUpdate(
        id: String,
        returnIfFound: Bool = false,
        coreDataCompletion: @escaping (UserEssentials) -> Void
    ) async throws -> UserEssentials? {
        do {
            if let user = try dataManager.fetchUser(withID: id),
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
    
    func getUserEssentialsAndUpdate(
        ids: Set<String>,
        updateAll: Bool = false,
        coreDataCompletion: @escaping ([UserEssentials]) -> Void
    ) async throws -> [UserEssentials] {
        var toFetch = Set<String>()
        do {
            let users = try dataManager.fetchUsers(withIDs: ids).compactMap { uEntity in
                if let uEssentials = try? UserEssentials(entity: uEntity), let savedAt = uEntity.savedAt {
                    if updateAll || Date().timeIntervalSince(savedAt) > 60 * 60 * 24 {
                        toFetch.insert(uEssentials.id)
                    }
                    
                    return uEssentials
                }
                return nil
            }
            
            ids.filter { id in
                !users.contains { $0.id == id }
            }.forEach { id in
                toFetch.insert(id)
            }
            
            coreDataCompletion(users)
        } catch {
            toFetch = ids
            presentErrorToast(error, silent: true)
        }
        
        guard !toFetch.isEmpty else { return [] }
        
        struct RequestBody: Encodable {
            let ids: [String]
        }
        
        let body = try apiManager.createRequestBody(RequestBody(ids: toFetch.sorted()))
        let data: APIResponse<[UserEssentials]> = try await apiManager.requestData("/users/by-ids", method: .post, body: body)
        
        // update CoreData
        try? self.dataManager.saveUsers(userEssentialsList: data.data)
        
        return data.data
    }
    
    func fetch(id: String) async throws -> UserDetail {
        let token = try await auth.getToken()
        
        let data: APIResponse<UserDetail> = try await apiManager.requestData("/users/\(id)", method: .get, token: token)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: UserEssentials(userDetail: data.data))
        
        return data.data
    }
    
    func fetch(username: String) async throws -> UserDetail {
        let token = try await auth.getToken()
        
        let data: APIResponse<UserDetail> = try await apiManager.requestData("/users/@\(username)", method: .get, token: token)
        
        // update CoreData
        try? self.dataManager.saveUser(userEssentials: UserEssentials(userDetail: data.data))
        
        return data.data
    }
    
    func getFollowRequests(page: Int = 1, limit: Int = 30) async throws -> APIResponseWithPagination<[FollowRequest]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[FollowRequest]> = try await apiManager.requestData("/users/followRequests?page=\(page)&limit=\(limit)", method: .get, token: token)
        
        return data
    }
    
    func follow(id: String) async throws -> FollowRequestStatus {
        let token = try await auth.getToken()
        
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
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/\(id)/connections", method: .delete, token: token)
    }
    
    func removeFollower(id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/followers/\(id)", method: .delete, token: token)
    }
    
    func acceptRequest(for requestId: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/followRequests/\(requestId)", method: .post, token: token)
    }
    
    func rejectRequest(for requestId: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/followRequests/\(requestId)", method: .delete, token: token)
    }
    
    func block(id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/\(id)/block", method: .post, token: token)
    }
    
    func unblock(id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/\(id)/block", method: .delete, token: token)
    }
    
    @discardableResult
    func getReferredUsers() async throws -> APIResponseWithPagination<[UserEssentialsWithCreationDate]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[UserEssentialsWithCreationDate]> = try await apiManager.requestData("/users/latestReferrals", method: .get, token: token)
        
        UserDataStack.shared.saveUsers(userEssentialsList: data.data)
        
        return data
    }
    
    func getStats() async throws -> UserStats {
        let token = try await auth.getToken()
        
        let data: APIResponse<UserStats> = try await apiManager.requestData("/users/stats", method: .get, token: token)
        
        return data.data
    }
    
    func sendPhoneVerificationCode(phone: String) async throws {
        let token = try await auth.getToken()
        
        struct GetPhoneVerificationBody: Encodable {
            let phone: String
        }
        
        let reqBody = try apiManager.createRequestBody(GetPhoneVerificationBody(phone: phone))
        try await apiManager.requestNoContent("/auth/verify-phone", method: .post, body: reqBody, token: token)
    }
    
    func verifyPhoneNumber(phone: String, code: String) async throws {
        let token = try await auth.getToken()
        
        struct VerifyPhoneBody: Encodable {
            let phone: String
            let code: String
        }
        
        let reqBody = try apiManager.createRequestBody(VerifyPhoneBody(phone: phone, code: code))
        try await apiManager.requestNoContent("/auth/verify-phone", method: .patch, body: reqBody, token: token)
    }
    
    func editProfileInfo(changes: EditUserBody) async throws {
        guard let uid = auth.currentUser?.id else {
            throw URLError(.badServerResponse)
        }
        
        let token = try await auth.getToken()
        
        let reqBody = try apiManager.createRequestBody(changes)
        try await apiManager.requestNoContent("/users/\(uid)", method: .put, body: reqBody, token: token)
    }
    
    // MARK: - Response Models
    
    struct EditUserBody: Encodable {
        let name: String?
        let username: String?
        let bio: String?
        let removeProfileImage: Bool?
        
        let eula: Bool?
        let referrer: String?
        
        init(name: String? = nil, username: String? = nil, bio: String? = nil, removeProfileImage: Bool? = nil) {
            self.name = name
            self.username = username
            self.bio = bio
            self.removeProfileImage = removeProfileImage
            
            self.eula = nil
            self.referrer = nil
        }
        
        init(eula: Bool, referrer: String?, name: String?, username: String?, bio: String?, removeProfileImage: Bool?) {
            self.name = name
            self.username = username
            self.bio = bio
            self.removeProfileImage = removeProfileImage
            self.eula = eula
            self.referrer = referrer
        }
    }
    
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
