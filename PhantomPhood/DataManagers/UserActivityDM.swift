//
//  UserActivityDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import Foundation

struct UserActivityDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getUserActivity(_ id: String) async throws -> FeedItem {
        let token = try await auth.getToken()
        
        let data: APIResponse<FeedItem> = try await apiManager.requestData("/feeds/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    func getUserActivities(_ userId: String, page: Int, activityType: FeedItemActivityType?, limit: Int = 20) async throws -> APIResponseWithPagination<[FeedItem]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[FeedItem]> = try await apiManager.requestData("/users/\(userId)/userActivities", method: .get, queryParams: [
            "page": String(page),
            "limit": String(limit),
            "type": activityType?.rawValue
        ], token: token)
        
        return data
    }
    
    func getUserActivities(_ userId: String, page: Int, activityTypes: [FeedItemActivityType], limit: Int = 20) async throws -> APIResponseWithPagination<[FeedItem]> {
        let token = try await auth.getToken()
        
        let types = activityTypes.map { $0.rawValue }.joined(separator: ",")
        let data: APIResponseWithPagination<[FeedItem]> = try await apiManager.requestData("/users/\(userId)/userActivities", method: .get, queryParams: [
            "page": String(page),
            "limit": String(limit),
            "types": types
        ], token: token)
        
        return data
    }
    
    func getActivityComments(for activityId: String, page: Int , limit: Int = 20) async throws -> APIResponseWithPagination<CommentsResponse> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<CommentsResponse> = try await apiManager.requestData("/feeds/\(activityId)/comments", queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    struct CommentsResponse: Decodable {
        let comments: [Comment]
        let replies: [Comment]
    }
}
