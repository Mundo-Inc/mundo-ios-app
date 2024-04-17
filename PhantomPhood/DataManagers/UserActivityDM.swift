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
        
        let data: APIResponse<FeedItem> = try await apiManager.requestData("/feeds/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getUserActivities(_ userId: String, page: Int, activityType: FeedItemActivityType) async throws -> APIResponseWithPagination<[FeedItem]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[FeedItem]> = try await apiManager.requestData("/users/\(userId)/userActivities?page=\(page)\(activityType == .all ? "" : "&type=\(activityType.rawValue)")", method: .get, token: token)
        
        return data
    }
}
