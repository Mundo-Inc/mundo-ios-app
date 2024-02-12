//
//  UserSettings.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/12/24.
//

import Foundation
import SwiftUI

struct UserSettings {
    static let shared = UserSettings()

    private init() {}
    
    // MARK: - User Info
    
    @AppStorage("userRole") private(set) var userRole: UserRole = .user

    // MARK: - App settings

    @AppStorage("isBetaTester") var isBetaTester: Bool = false
    @AppStorage("referralsGenerated") var referralsGenerated: Int = 0

    /// Onboarding Version
    @AppStorage("onboardingVersion") var onboardingVersion: Int = 0
    
    // MARK: - Public Methods

    /// Cleans up user defaults on logout
    func logoutCleanup() {
        userRole = .user
        isBetaTester = false
    }
    
    /// Used in sign in flow to set user information
    func setUserInfo(_ user: CurrentUserFullData) {
        userRole = user.role
    }
}

