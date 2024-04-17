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
        let tokens = try await helper.startSignInWithAppleFlow()
        let result = await Authentication.shared.signinWithApple(tokens: tokens)
        if !result.success {
            self.error = result.error
        }
    }
}
