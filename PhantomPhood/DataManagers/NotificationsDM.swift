//
//  NotificationsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

final class NotificationsDM {
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
    
    func getNotifications(page: Int = 1, unread: Bool = false) async throws -> APIResponseWithPagination<[Notification]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[Notification]> = try await apiManager.requestData("/notifications?page=\(page)&limit=30\(unread ? "&unread=true" : "")&v=2", method: .get, token: token)
        
        return data
    }
    
    func markNotificationsAsRead() async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct RequestBody: Encodable {
            let date: Int
        }
        
        let body = try apiManager.createRequestBody(RequestBody(date: Int(Date().timeIntervalSince1970) * 1000))
        
        try await apiManager.requestNoContent("/notifications/read", method: .put, body: body, token: token)
    }
}
