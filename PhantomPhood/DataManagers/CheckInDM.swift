//
//  CheckInDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

final class CheckInDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getCheckins(event: String, page: Int = 1, limit: Int = 20) async throws -> [Checkin] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let data = try await apiManager.requestData("/checkins?event=\(event)&page=\(page)&limit=\(limit)", token: token) as APIResponse<[Checkin]>? else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
}
