//
//  LeaderboardDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct LeaderboardDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func fetchLeaderboard(page: Int = 1, limit: Int = 30) async throws -> [UserEssentials] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[UserEssentials]> = try await apiManager.requestData("/users/leaderboard", method: .get, queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data.data
    }
}
