//
//  LeaderboardDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

final class LeaderboardDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
        
    func fetchLeaderboard(page: Int = 1, limit: Int = 30) async throws -> [UserEssentials] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[UserEssentials]> = try await apiManager.requestData("/users/leaderboard", method: .get, queryParams: [
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data.data
    }
}
