//
//  RewardsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation

struct RewardsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    // MARK: - Public methods
    
    func claimDailyRewards() async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/rewards/daily/claim", method: .post, token: token)
    }
    
    func getMissions() async throws -> [Mission] {
        let token = try await auth.getToken()
        
        let resData: APIResponse<[Mission]> = try await apiManager.requestData("/rewards/missions", method: .get, token: token)
        
        return resData.data
    }
    
    func claimMission(missionId id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/rewards/missions/\(id)/claim", method: .post, token: token)
    }
    
    func getPrizes() async throws -> [Prize] {
        let token = try await auth.getToken()
        
        let resData: APIResponse<[Prize]> = try await apiManager.requestData("/rewards/prizes", method: .get, token: token)
        
        return resData.data
    }
    
    func redeemPrize(id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/rewards/prizes/\(id)/redeem", method: .post, token: token)
    }
    
    func cashOut() async throws -> CashOutResponse {
        let token = try await auth.getToken()
        
        let data: APIResponse<CashOutResponse> = try await apiManager.requestData("/rewards/cashout", method: .post, token: token)
        
        return data.data
    }
    
    struct CashOutResponse: Decodable {
        let message: String?
    }
}
