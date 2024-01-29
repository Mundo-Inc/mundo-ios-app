//
//  UserActivityDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import Foundation

final class UserActivityDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func getUserActivity(_ id: String) async throws -> FeedItem {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/feeds/\(id)", method: .get, token: token) as APIResponse<FeedItem>?
        
        if let data = data {
            return data.data
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
