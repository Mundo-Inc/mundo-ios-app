//
//  NotificationsDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class NotificationsDataManager {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    struct FeedResponse: Decodable {
        let success: Bool
        let data: FeedResponseData
        let hasMore: Bool
        
        struct FeedResponseData: Decodable {
            let notifications: [Notification]
            let total: Int
        }
    }
    
    func getNotifications(page: Int = 1) async throws -> FeedResponse {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/notifications?page=\(page)&limit=30", method: .get, token: token) as FeedResponse?
        
        if let data = data {
            return data
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
