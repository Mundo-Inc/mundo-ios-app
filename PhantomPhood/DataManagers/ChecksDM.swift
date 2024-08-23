//
//  ChecksDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/29/24.
//

import Foundation

struct ChecksDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func checkUsername(_ username: String) async throws {
        if auth.userSession != nil, let token = try? await auth.getToken() {
            try await apiManager.requestNoContent("/users/username-availability/\(username)", token: token)
        } else {
            try await apiManager.requestNoContent("/users/username-availability/\(username)")
        }
    }
}
