//
//  UserSettings.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/12/24.
//

import Foundation
import SwiftUI

struct UserSettings {
    static let maxInviteCredits = 3
    static let shared = UserSettings()
    
    private init() {}
    
    // MARK: - User Info
    
    @AppStorage(Keys.userRole.rawValue) private(set) var userRole: UserRole = .user
    
    // MARK: - App settings
    
    @AppStorage(Keys.isBetaTester.rawValue) var isBetaTester: Bool = false
    
    @AppStorage(Keys.inviteCredits.rawValue) var inviteCredits: Int = UserSettings.maxInviteCredits
    @AppStorage(Keys.inviteCreditsLastGiven.rawValue) var inviteCreditsLastGiven: Date = .now
    
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
        
        /// User role - (user, admin)
        case userRole

        /// Beta tester status
        case isBetaTester

        /// Referral code (used in sign up flow)
        case referredBy
        
        /// Number of new invites user can generate
        case inviteCredits
        /// Last time user was given invite credits
        case inviteCreditsLastGiven

        /// Onboarding Version
        case onboardingVersion
        
    }
}

