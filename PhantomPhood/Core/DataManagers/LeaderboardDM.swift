//
//  LeaderboardDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class LeaderboardDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
        
    struct LeaderboardResponse: Decodable {
        let success: Bool
        let data: [User]
    }
    
    func fetchLeaderboard(page: Int = 1) async throws -> [User] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/users/leaderboard?page=\(page)&limit=30", method: .get, token: token) as LeaderboardResponse?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
}
