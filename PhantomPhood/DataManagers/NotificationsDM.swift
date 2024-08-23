//
//  NotificationsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct NotificationsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getNotifications(page: Int = 1, unread: Bool = false) async throws -> APIResponseWithPagination<[Notification]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[Notification]> = try await apiManager.requestData("/notifications", method: .get, queryParams: [
            "page": String(page),
            "limit": "30",
            "unread": unread ? "true" : nil,
            "v": "2",
        ], token: token)
        
        return data
    }
    
    func markNotificationsAsRead() async throws {
        let token = try await auth.getToken()
        
        struct RequestBody: Encodable {
            let date: Int
        }
        
        let body = try apiManager.createRequestBody(RequestBody(date: Int(Date().timeIntervalSince1970) * 1000))
        
        try await apiManager.requestNoContent("/notifications/read", method: .put, body: body, token: token)
    }
}
