//
//  SettingsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

final class SettingsVM: LoadingSections, ObservableObject {
    static let accountDM = AccountDM()
    
    @Published var isAccountSettingsVisible: Bool = false
    @Published var loadingSections = Set<LoadingSection>()
    
    // MARK: Methods
    
    func deleteAccount() async {
        do {
            try await Self.accountDM.deleteAccount()
            
            ToastVM.shared.toast(.init(type: .success, title: "Success", message: "Your account has been deleted"))
            
            await Authentication.shared.signOut()
        } catch {
            presentErrorToast(error, title: "Unable to delete your account")
        }
    }
    
    func resetPasswordRequest() async {
        guard let userEmail = Authentication.shared.currentUser?.email.address else { return }
        
        await setLoadingState(.resetPassword, to: true)
        do {
            try await Authentication.shared.requestResetPassword(email: userEmail)
            
            ToastVM.shared.toast(.init(type: .success, title: "Email Sent", message: "Email sent"))
        } catch {
            presentErrorToast(error, function: #function)
        }
        await setLoadingState(.resetPassword, to: false)
    }
        
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case resetPassword
    }
}
