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
        
    func fetchLeaderboard(page: Int = 1) async throws -> [UserEssentials] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[UserEssentials]> = try await apiManager.requestData("/users/leaderboard?page=\(page)&limit=30", method: .get, token: token)
        
        return data.data
    }
}
