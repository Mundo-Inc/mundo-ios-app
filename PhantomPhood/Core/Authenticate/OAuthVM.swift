//
//  OAuthVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import Foundation
import SwiftUI

@MainActor
final class OAuthVM: ObservableObject {
    @ObservedObject var auth = Authentication.shared
    
    @Published var error: String? = nil
    @Published var isLoading = false
    
    func signInGoogle() async throws {
        self.isLoading = true
        do {
            let helper = SignInGoogleHelper()
            let tokens = try await helper.signIn()
            let result = await auth.signinWithGoogle(tokens: tokens)
            if !result.success {
                self.error = result.error
            }
            self.isLoading = false
        } catch {
            self.isLoading = false
            throw error
        }
    }
    
    func signInApple() async throws {
        self.isLoading = true
        do {
            let helper = SignInWithAppleHelper.shared
            let tokens = try await helper.startSignInWithAppleFlow()
            let result = await auth.signinWithApple(tokens: tokens)
            if !result.success {
                self.error = result.error
            }
            self.isLoading = false
        } catch {
            self.isLoading = false
            throw error
        }
    }
}
