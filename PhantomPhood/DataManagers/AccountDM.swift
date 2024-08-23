//
//  AccountDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

struct AccountDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func deleteAccount() async throws {
        guard let userId = auth.currentUser?.id else {
            throw URLError(.badServerResponse)
        }
        
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/users/\(userId)", method: .delete, token: token)
    }
    
    func setPrivacy(to: Bool) async throws {
        guard let userId = auth.currentUser?.id else {
            throw URLError(.badServerResponse)
        }
        
        let token = try await auth.getToken()
        
        struct RequestBody: Encodable {
            let isPrivate: Bool
        }
        
        let body = try apiManager.createRequestBody(RequestBody(isPrivate: to))
        try await apiManager.requestNoContent("/users/\(userId)/privacy", method: .put, body: body, token: token)
    }
}
