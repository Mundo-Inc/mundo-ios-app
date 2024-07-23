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
    
    func getNotifications(page: Int = 1, unread: Bool = false) async throws -> APIResponseWithPagination<[Notification]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[Notification]> = try await apiManager.requestData("/notifications", method: .get, queryParams: [
            "page": page.description,
            "limit": "30",
            "unread": unread ? "true" : nil,
            "v": "2",
        ], token: token)
        
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
