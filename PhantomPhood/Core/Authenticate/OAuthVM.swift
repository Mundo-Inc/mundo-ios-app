//
//  OAuthVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import Foundation

@MainActor
final class OAuthVM: ObservableObject {
    @Published var error: String? = nil
    @Published private(set) var isLoading = false
    
    func signInGoogle() async throws {
        self.isLoading = true

        defer {
            self.isLoading = false
        }
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let result = await Authentication.shared.signinWithGoogle(tokens: tokens)
        if !result.success {
            self.error = result.error
        }
    }
    
    func signInApple() async throws {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        let helper = SignInWithAppleHelper.shared
        let res = try await helper.startSignInWithAppleFlow()
        switch res {
        case .token(let signInWithAppleResult):
            let result = await Authentication.shared.signinWithApple(tokens: signInWithAppleResult)
            if !result.success {
                self.error = result.error
            }
        case .credentials(let username, let password):
            let result = await Authentication.shared.signIn(email: username, password: password)
            if !result.success {
                self.error = result.error
            }
        }
    }
}
