//
//  ConnectionsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/31/23.
//

import Foundation

final class ConnectionsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    enum UserConnectionType: String {
        case followings = "followings"
        case followers = "followers"
    }
    
    func getConnections(userId: String, type: UserConnectionType, page: Int = 1, limit: Int = 30) async throws -> APIResponseWithPagination<[UserConnection]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[UserConnection]> = try await apiManager.requestData("/users/\(userId)/connections/\(type.rawValue)?page=\(page)&limit=\(limit)", method: .get, token: token)
        
        return data
    }
    
    func follow(userId: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/users/\(userId)/connections", method: .post, token: token)
    }
    
    func followStatus(userId: String) async throws -> FollowStatus {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<FollowStatus> = try await apiManager.requestData("/users/\(userId)/connections/followStatus", method: .get, token: token)
        
        return data.data
    }
    
    // MARK: - Structs
    
    struct FollowStatus: Decodable {
        let followedByUser: Bool
        let followsUser: Bool
    }
}
