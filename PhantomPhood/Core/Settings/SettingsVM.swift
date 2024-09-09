//
//  SettingsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

final class SettingsVM: LoadingSections, ObservableObject {
    private let accountDM = AccountDM()
    
    @Published var isAccountSettingsVisible: Bool = false
    @Published var isAdvancedSettingsVisible: Bool = false
    @Published var loadingSections = Set<LoadingSection>()
    
    // MARK: Methods
    
    func deleteAccount() async {
        do {
            try await accountDM.deleteAccount()
            
            ToastVM.shared.toast(.init(type: .success, title: "Success", message: "Your account has been deleted"))
            
            await Authentication.shared.signOut()
        } catch {
            presentErrorToast(error, title: "Unable to delete your account")
        }
    }
    
    func resetPasswordRequest() async {
        guard let userEmail = Authentication.shared.currentUser?.email.address else { return }
        
        setLoadingState(.resetPassword, to: true)
        do {
            try await Authentication.shared.requestResetPassword(email: userEmail)
            
            ToastVM.shared.toast(.init(type: .success, title: "Email Sent", message: "Email sent"))
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.resetPassword, to: false)
    }
    
    func setAccountPrivacy(to isPrivate: Bool) async {
        setLoadingState(.accountPrivacyRequest, to: true)
        do {
            try await accountDM.setPrivacy(to: isPrivate)
            await Authentication.shared.updateUserInfo()
            ToastVM.shared.toast(.init(type: .success, title: "Account Privacy Changed", message: "Your account is \(isPrivate ? "Private" : "Public") now"))
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.accountPrivacyRequest, to: false)
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case resetPassword
        case accountPrivacyRequest
    }
}
