//
//  OAuthVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import Foundation

final class OAuthVM: ObservableObject, LoadingSections {
    @Published var error: String? = nil
    
    @Published var loadingSections = Set<LoadingSection>()
    
    func signInGoogle() async {
        guard !loadingSections.contains(.signIn) else { return }
        
        setLoadingState(.signIn, to: true)

        defer {
            setLoadingState(.signIn, to: false)
        }
        
        let helper = SignInGoogleHelper()
        
        do {
            let tokens = try await helper.signIn()
            try await Authentication.shared.signinWithGoogle(tokens: tokens)
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    func signInApple() async {
        guard !loadingSections.contains(.signIn) else { return }
        
        setLoadingState(.signIn, to: true)

        defer {
            setLoadingState(.signIn, to: false)
        }
        
        let helper = SignInWithAppleHelper.shared
        
        do {
            let res = try await helper.startSignInWithAppleFlow()
            switch res {
            case .token(let signInWithAppleResult):
                try await Authentication.shared.signinWithApple(tokens: signInWithAppleResult)
            case .credentials(let username, let password):
                try await Authentication.shared.signIn(email: username, password: password)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    enum LoadingSection: Hashable {
        case signIn
    }
}

