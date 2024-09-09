//
//  ReviewDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/1/24.
//

import Foundation

struct ConversationDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func create(recipient: String, content: String) async throws -> APIResponse<Conversation> {
        let token = try await auth.getToken()
        
        struct Body: Encodable {
            let recipient: String
            let content: String
        }
        
        let body = try apiManager.createRequestBody(Body(recipient: recipient, content: content))
        let data: APIResponse<Conversation> = try await apiManager.requestData("/conversations", method: .post, body: body, token: token)
        
        return data
    }
    
    func getConversations(page: Int = 1, limit: Int = 100) async throws -> APIResponseWithPagination<[Conversation]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[Conversation]> = try await apiManager.requestData("/conversations", queryParams: [
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func getCovnersation(id: String) async throws -> APIResponse<Conversation> {
        let token = try await auth.getToken()
        
        let data: APIResponse<Conversation> = try await apiManager.requestData("/conversations/\(id)", token: token)
        
        return data
    }
    
    func getCovnersationWith(userId: String) async throws -> APIResponse<Conversation> {
        let token = try await auth.getToken()
        
        let data: APIResponse<Conversation> = try await apiManager.requestData("/conversations/with/\(userId)", token: token)
        
        return data
    }
    
    func getMessages(covnersation: String, lastMessage: String? = nil, limit: Int = 100) async throws -> APIResponse<[ConversationMessageEssentials]> {
        let token = try await auth.getToken()
        
        let data: APIResponse<[ConversationMessageEssentials]> = try await apiManager.requestData("/conversations/\(covnersation)/messages", queryParams: [
            "lastMessage": lastMessage,
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func delete(covnersation: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/conversations/\(covnersation)", method: .delete, token: token)
    }
}
