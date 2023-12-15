//
//  ConnectionsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/31/23.
//

import Foundation

class ConnectionsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    enum UserConnectionType: String {
        case followings = "followings"
        case followers = "followers"
    }
    
    func getConnections(userId: String, type: UserConnectionType, page: Int = 1, limit: Int = 30) async throws -> (data: [UserConnection], total: Int) {
        guard let token = await auth.getToken() else { throw URLError(.userAuthenticationRequired) }
        
        struct RequestResponse: Decodable {
            let success: Bool
            let data: [UserConnection]
            let total: Int
        }
        
        let data = try await apiManager.requestData("/users/\(userId)/connections/\(type.rawValue)?page=\(page)&limit=\(limit)", method: .get, token: token) as RequestResponse?
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return (data: data.data, total: data.total)
    }
}
