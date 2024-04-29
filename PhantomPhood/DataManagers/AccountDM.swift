//
//  AccountDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

final class AccountDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func deleteAccount() async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let userId = auth.currentUser?.id else {
            throw URLError(.badServerResponse)
        }
        
        try await apiManager.requestNoContent("/users/\(userId)", method: .delete, token: token)
    }
}
