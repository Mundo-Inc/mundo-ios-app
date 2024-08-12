//
//  SignUpWithPasswordVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/6/24.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class SignUpWithPasswordVM: ObservableObject {
    private let checksDM = ChecksDM()
    private let searchDM = SearchDM()
    private let userProfileDM = UserProfileDM()
    
    enum LoadingSection: Hashable {
        case username
        case userSearch
        case getReferredBy
        case submit
    }
    
    @Published var step: Step = .email
    @Published var direction = 1
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var eula = false
    
    @Published var email: String = "" {
        didSet {
            isValidEmail = Validator.email(email)
        }
    }
    @Published private(set) var isValidEmail: Bool = false
    
    @Published var name: String = ""
    
    @Published var username: String = ""
    @Published private(set) var isUsernameValid: Bool = false
    @Published private(set) var usernameError: String? = nil
    
    @Published var password: String = ""
    
    @Published var error: String?
    
    @Published var showPasteButton = UIPasteboard.general.hasURLs
    @Published var referredBy: UserEssentials? = nil
    
    @Published var suggestedUsersList: [UserEssentials] = []
    @Published var userSearch: String = "" {
        didSet {
            if userSearch.isEmpty {
                suggestedUsersList.removeAll()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                Task {
                    await self?.checkUsername(value)
                }
            }
            .store(in: &cancellables)
        
        $userSearch
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard value.count >= 3 else { return }
                
                Task {
                    await self?.searchUsers(q: value)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkUsername(_ username: String) async {
        guard username.count >= 5 else {
            self.isUsernameValid = false
            if username.count > 0 {
                self.usernameError = "Username must be at least 5 characters"
            }
            return
        }
        
        self.loadingSections.insert(.username)
        do {
            try await self.checksDM.checkUsername(username)
            self.isUsernameValid = true
        } catch {
            self.isUsernameValid = false
            self.usernameError = getErrorMessage(error)
        }
        self.loadingSections.remove(.username)
    }
    
    private func searchUsers(q: String) async {
        self.loadingSections.insert(.userSearch)
        do {
            let users = try await searchDM.searchUsers(q: q)
            withAnimation {
                self.suggestedUsersList = users
            }
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.userSearch)
    }
    
    func getRefferedBy(id: String) async {
        self.loadingSections.insert(.getReferredBy)
        do {
            let user = try await userProfileDM.getUserEssentials(id: id)
            withAnimation {
                self.referredBy = user
            }
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.getReferredBy)
    }
    
    func submit() async {
        loadingSections.insert(.submit)
        do {
            try await Authentication.shared.signUp(name: name, email: email, password: password, username: username.count >= 5 ? username : nil, referrer: referredBy?.id)
        } catch {
            withAnimation {
                self.error = getErrorMessage(error)
            }
        }
        self.loadingSections.remove(.submit)
    }
    
    var isValid: Bool {
        switch step {
        case .email:
            isValidEmail
        case .name:
            true
        case .username:
            isUsernameValid
        case .password:
            password.count >= 5
        case .referral:
            true
        case .tos:
            eula
        }
    }
    
    enum Step: Hashable {
        case email
        case name
        case username
        case password
        case referral
        case tos
        
        var backButtonTitle: String {
            switch self {
            case .email:
                "Cancel"
            default:
                "Back"
            }
        }
        
        var nextButtonTitle: String {
            switch self {
            case .tos:
                "Sign Up"
            default:
                "Next"
            }
        }
    }
}
