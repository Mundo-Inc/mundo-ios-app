//
//  ReactionsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation

@MainActor
class ReactionsViewModel: ObservableObject {
    let activityId: String
    
    init(activityId: String) {
        self.activityId = activityId
    }
    
    let apiManager = APIManager()
    let auth = Authentication.shared
    
    @Published var isLoading = false
    
    func addReaction(type: ReactionType, reaction: String) async throws -> RequestResponse.ReactionData {
        guard let token = auth.token else {
            throw URLError(.userAuthenticationRequired)
        }
        
        self.isLoading = true
        let body = try apiManager.createRequestBody(RequestBody(target: activityId, type: type.rawValue, reaction: reaction))
        let (data, _) = try await apiManager.request("/reactions", method: .post, body: body, token: token) as (RequestResponse?, HTTPURLResponse)
        self.isLoading = false
        
        if let data = data {
            return data.data
        } else {
            throw CancellationError()
        }
    }
    func removeReaction(id: String) async throws {
        guard let token = auth.token else {
            throw URLError(.userAuthenticationRequired)
        }
        
        self.isLoading = true
        let _ = try await apiManager.requestNoContent("/reactions/\(id)", method: .delete, token: token)
        self.isLoading = false
    }
    
    
    struct RequestBody: Encodable {
        let target: String
        let type: String
        let reaction: String
    }
    struct RequestResponse: Decodable {
        let success: Bool
        let data: ReactionData
        
        struct ReactionData: Decodable, Identifiable {
            let _id: String
            let user: String
            let target: String
            let type: ReactionType
            let reaction: String
            let createdAt: String
            
            var id: String {
                self._id
            }
        }
    }
}
