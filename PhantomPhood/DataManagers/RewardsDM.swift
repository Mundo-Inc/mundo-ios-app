//
//  RewardsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation

final class RewardsDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    // MARK: - Public methods
    
    func getDailyRewardsInfo() async throws -> DailyRewardsInfoResponse {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let resData: APIResponse<DailyRewardsInfoResponse> = try await apiManager.requestData("/rewards/daily", method: .get, token: token)
        
        return resData.data
    }
    
    func claimDailyRewards() async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/rewards/daily/claim", method: .post, token: token)
    }
    
    func getMissions() async throws -> [Mission] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let resData: APIResponse<[Mission]> = try await apiManager.requestData("/rewards/missions", method: .get, token: token)
        
        return resData.data
    }
    
    func claimMission(missionId id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/rewards/missions/\(id)/claim", method: .post, token: token)
    }
    
    func getPrizes() async throws -> [Prize] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let resData: APIResponse<[Prize]> = try await apiManager.requestData("/rewards/prizes", method: .get, token: token)
        
        return resData.data
    }
    
    func redeemPrize(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/rewards/prizes/\(id)/redeem", method: .post, token: token)
    }
    
    // MARK: - Structs
    
    struct DailyRewardsInfoResponse: Codable {
        let phantomCoins: PhantomCoins
        let dailyRewards: [Int]
    }
}
