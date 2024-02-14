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
    
    @AppStorage(Keys.userRole.rawValue) private(set) var userRole: UserRole = .user

    // MARK: - App settings

    @AppStorage(Keys.isBetaTester.rawValue) var isBetaTester: Bool = false
    @AppStorage(Keys.referralsGenerated.rawValue) var referralsGenerated: Int = 0

    /// Onboarding Version
    @AppStorage(Keys.onboardingVersion.rawValue) var onboardingVersion: Int = 0
    
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
    
    enum Keys: String, CaseIterable {
        case userRole
        case isBetaTester
        case referralsGenerated
        case referredBy
        case onboardingVersion
    }
}

