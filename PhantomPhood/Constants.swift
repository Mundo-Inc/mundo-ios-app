//
//  Constants.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/3/24.
//

import Foundation

struct K {
    static let appURLScheme = "phantom"
    static let appDomain = "phantomphood.ai"
    
    struct UserDefaults {
        static let isMute = "isMute"
        static let theme = "theme"
        
        /// User role - (user, admin)
        static let userRole = "userRole"
        
        /// Beta tester status
        static let isBetaTester = "isBetaTester"
        
        /// Referral code (used in sign up flow)
        static let referredBy = "referredBy"
        
        /// Number of new invites user can generate
        static let inviteCredits = "inviteCredits"
        /// Last time user was given invite credits
        static let inviteCreditsLastGiven = "inviteCreditsLastGiven"
        
        /// Onboarding Version
        static let onboardingVersion = "onboardingVersion"
        
        static let appTerminatedGracefully = "appTerminatedGracefully"
        
        static let apnToken = "apnToken"
        static let fcmToken = "fcmToken"
        
        static let contactsLastSyncDate = "contactsLastSyncDate"
        
        private init() {}
    }
    
    struct CoordinateSpace {
        static let myProfile = "MyProfile"
        static let userProfile = "UserProfile"
    }
    
    private init() {}
}
