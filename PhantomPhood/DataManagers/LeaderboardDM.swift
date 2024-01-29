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
        
    func fetchLeaderboard(page: Int = 1) async throws -> [UserOverview] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/leaderboard?page=\(page)&limit=30", method: .get, token: token) as APIResponse<[UserOverview]>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
}
