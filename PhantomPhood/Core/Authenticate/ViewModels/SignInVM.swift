//
//  SignInVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/8/24.
//

import Foundation

final class SignInVM: ObservableObject, LoadingSections {
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var error: String?
    
    @Published var showResetPassword = false
    
    var isValidPassword: Bool {
        password.isValidPassword
    }
    
    var isValidEmail: Bool {
        email.isValidEmail
    }
    
    func signIn() async {
        guard !loadingSections.contains(.signIn) else { return }
        
        setLoadingState(.signIn, to: true)
        
        defer {
            setLoadingState(.signIn, to: false)
        }
        
        do {
            try await Authentication.shared.signIn(email: email, password: password)
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    func requestPasswordReset() async {
        guard !loadingSections.contains(.requestPasswordReset) else { return }
        
        setLoadingState(.requestPasswordReset, to: true)
        
        defer {
            setLoadingState(.requestPasswordReset, to: false)
        }
        
        do {
            try await Authentication.shared.requestResetPassword(email: email)
            
            await MainActor.run {
                self.showResetPassword = false
            }
            ToastVM.shared.toast(.init(type: .success, title: "Email Sent", message: "Email sent"))
        } catch {
            presentErrorToast(error)
        }
    }
    
    enum LoadingSection: Hashable {
        case signIn
        case requestPasswordReset
    }
}
