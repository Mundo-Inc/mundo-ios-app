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
    
    // MARK: - App settings
    
    @AppStorage(K.UserDefaults.isBetaTester) var isBetaTester: Bool = false
    
    @AppStorage(K.UserDefaults.inviteCredits) var inviteCredits: Int = UserSettings.maxInviteCredits
    @AppStorage(K.UserDefaults.inviteCreditsLastGiven) var inviteCreditsLastGiven: Date = .now
    
    /// Onboarding Version
    @AppStorage(K.UserDefaults.onboardingVersion) var onboardingVersion: Int = 0
    
    // MARK: - Public Methods
    
    /// Cleans up user defaults on logout
    func logoutCleanup() {
        isBetaTester = false
    }
}

