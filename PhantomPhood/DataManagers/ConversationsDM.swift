//
//  ConversationsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation

final class ConversationsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getToken() async throws -> String {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<TokenResponse> = try await apiManager.requestData("/conversations/token", method: .get, token: token)
        
        return data.data.token
    }
    
    /// Creates a new conversation if it does not already exists
    /// Returns covnersation if it already exists
    func createConversation(with userId: String) async throws -> CreateConversationResponse {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct Body: Encodable {
            let user: String
        }
        
        let body = try apiManager.createRequestBody(Body(user: userId))
        let data: APIResponse<CreateConversationResponse> = try await apiManager.requestData("/conversations", method: .post, body: body, token: token)
        
        return data.data
    }
    
    func removeParticipantFromConversation(userId: String, from sid: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct Body: Encodable {
            let user: String
        }
        
        let body = try apiManager.createRequestBody(Body(user: userId))
        try await apiManager.requestNoContent("/conversations/\(sid)/participant", method: .delete, body: body, token: token)
    }
    
    // MARK: Structs
    
    struct CreateConversationResponse: Decodable {
        let id: String
        let friendlyName: String
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case friendlyName
        }
        
        var sid: String {
            self.id
        }
    }
    
    struct TokenResponse: Decodable {
        let token: String
    }
}
