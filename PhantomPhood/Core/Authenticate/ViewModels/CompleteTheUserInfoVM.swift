//
//  CompleteTheUserInfoVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/7/24.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CompleteTheUserInfoVM: ObservableObject {
    private let checksDM = ChecksDM()
    private let searchDM = SearchDM()
    private let userProfileDM = UserProfileDM()
    
    enum LoadingSection: Hashable {
        case username
        case userSearch
        case getReferredBy
        case submit
        case sendVerificationCode
        case submitPhoneVerification
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var step: Step = .name
    @Published var direction = 1
    
    @Published var eula = false
    
    @Published var phoneNumber: String = ""
    @Published var phoneVerificationCode: String = ""
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var currentUsername: String = ""
    @Published var isUsernameValid: Bool = true
    @Published var usernameError: String? = nil
    
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
    
    @Published var presentedSheet: Sheet? = nil
    @Published var selectedCountry: Country = Country.US
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard self?.username.isEmpty == false else {
                    self?.isUsernameValid = true
                    return
                }
                
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
    
    func searchUsers(q: String) async {
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
        guard !loadingSections.contains(.submit) else { return }
        
        loadingSections.insert(.submit)
        
        defer {
            loadingSections.remove(.submit)
        }
        
        do {
            try await userProfileDM.editProfileInfo(changes: .init(eula: eula, referrer: referredBy?.id, name: self.name, username: username.isEmpty ? nil : username, bio: nil, removeProfileImage: nil))
            await Authentication.shared.updateUserInfo()
        } catch {
            withAnimation {
                self.error = getErrorMessage(error)
            }
        }
    }
    
    func sendVerificationCode() async throws {
        guard !loadingSections.contains(.sendVerificationCode) else { return }
        
        let number = "\(selectedCountry.dialCode)\(phoneNumber.numbersOnly)"
        
        guard number.isValidPhoneNumber else {
            ToastVM.shared.toast(.init(type: .userError, title: "Invalid Phone Number", message: "Please enter a valid phone number"))
            return
        }
        
        loadingSections.insert(.sendVerificationCode)
        
        defer {
            loadingSections.remove(.sendVerificationCode)
        }
        
        do {
            try await userProfileDM.sendPhoneVerificationCode(phone: number)
            
            await Authentication.shared.updateUserInfo()
        } catch {
            withAnimation {
                self.error = getErrorMessage(error)
            }
        }
    }
    
    func verifyPhone() async {
        guard !loadingSections.contains(.submitPhoneVerification) else { return }
        
        let code = phoneVerificationCode.numbersOnly
        
        guard code.count == 5 else {
            ToastVM.shared.toast(.init(type: .userError, title: "Invalid Code", message: "Code must be 5 characters"))
            return
        }
        
        let number = "\(selectedCountry.dialCode)\(phoneNumber.numbersOnly)"
        
        guard number.isValidPhoneNumber else {
            ToastVM.shared.toast(.init(type: .userError, title: "Invalid Phone Number", message: "Please enter a valid phone number"))
            return
        }
        
        loadingSections.insert(.submitPhoneVerification)
        
        defer {
            loadingSections.remove(.submitPhoneVerification)
        }
        
        do {
            try await userProfileDM.verifyPhoneNumber(phone: number, code: code)
            
            await Authentication.shared.updateUserInfo()
        } catch {
            withAnimation {
                self.error = getErrorMessage(error)
            }
        }
    }
    
    func formatVerificationCode(code: String) -> String {
        let cleanNumber = code.numbersOnly
                
        let mask = "X X X X X"
        
        var result = ""
        var startIndex = cleanNumber.startIndex
        let endIndex = cleanNumber.endIndex
        
        for char in mask where startIndex < endIndex {
            if char == "X" {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
    
    var isValid: Bool {
        switch step {
//        case .phone:
//            "\(selectedCountry.dialCode)\(phoneNumber.numbersOnly)".isValidPhoneNumber
//        case .phoneVerification:
//            phoneVerificationCode.numbersOnly.count == 5
        case .name:
            true
        case .username:
            isUsernameValid
        case .referral:
            true
        case .tos:
            eula
        }
    }
    
    // MARK: - Enums
    
    enum Step: Hashable {
//        case phone
//        case phoneVerification
        case name
        case username
        case referral
        case tos
        
        var backButtonTitle: String {
            if Authentication.shared.currentUser?.acceptedEula == nil {
//                switch self {
//                case .phone:
//                    "Cancel"
//                default:
//                    "Back"
//                }
                "Back"
            } else {
//                switch self {
//                case .phone:
//                    "Switch Account"
//                default:
//                    "Back"
//                }
                "Back"
            }
        }
        
        var nextButtonTitle: String {
            if Authentication.shared.currentUser?.acceptedEula == nil {
                switch self {
                case .tos:
                    "Finish Sign Up"
                default:
                    "Next"
                }
            } else {
//                switch self {
//                case .phone:
//                    "Send Code"
//                default:
//                    "Verify"
//                }
                "Verify"
            }
        }
    }
    
    enum Sheet: String, Identifiable, Hashable {
        case countryPicker
        
        var id: String {
            self.rawValue
        }
    }
}
