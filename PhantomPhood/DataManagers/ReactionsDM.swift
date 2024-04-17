//
//  ReactionsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import Foundation

final class ReactionsDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    // MARK: - Public methods
    
    func addReaction(type: ReactionType, reaction: String, for activityId: String) async throws -> UserReaction {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let body = try apiManager.createRequestBody(AddReactionRequestBody(target: activityId, type: type.rawValue, reaction: reaction))
        let resData: APIResponse<UserReaction> = try await apiManager.requestData("/reactions", method: .post, body: body, token: token)
        
        return resData.data
    }
    
    func removeReaction(reactionId: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/reactions/\(reactionId)", method: .delete, token: token)
    }
    
    // MARK: - Structs
    
    struct AddReactionRequestBody: Encodable {
        let target: String
        let type: String
        let reaction: String
    }
}
