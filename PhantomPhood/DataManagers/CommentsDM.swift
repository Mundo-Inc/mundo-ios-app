//
//  CommentsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/29/24.
//

import Foundation

final class CommentsDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func submitComment(for activityId: String, content: String, parent: String? = nil) async throws -> Comment {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct CreateCommentBody: Encodable {
            let content: String
            let activity: String
            let parent: String?
        }
        
        let body = try apiManager.createRequestBody(CreateCommentBody(content: content, activity: activityId, parent: parent))
        let data: APIResponse<Comment> = try await apiManager.requestData("/comments", method: .post, body: body, token: token)
        
        return data.data
    }
    
    func updateCommentLike(for commentId: String, action: LikeAction) async throws -> Comment {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<Comment> = try await apiManager.requestData("/comments/\(commentId)/likes", method: action == .add ? .post : .delete, token: token)
        
        return data.data
    }
    
    func getReplies(for commentId: String, page: Int = 1, limit: Int = 30) async throws -> [Comment] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[Comment]> = try await apiManager.requestData("/comments/\(commentId)/replies", method: .get, queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data.data
    }
    
    // MARK: Enums
    
    enum LikeAction {
        case add
        case remove
    }
}
