//
//  Constants.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/3/24.
//

import Foundation

struct K {
    static let appName = "Mundo"
    static let appURLScheme = "mundo"
    static let appDomain = "getmundo.ai"
    
    struct UserDefaults {
        static let isMute = "isMute"
        static let theme = "theme"
                
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
    
    struct ENV {
        static var APIBaseURL: String {
            Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as! String
        }
        static var GIDClientID: String {
            Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as! String
        }
        static var StripeDefaultPublishableKey: String {
            Bundle.main.object(forInfoDictionaryKey: "StripeDefaultPublishableKey") as! String
        }
        static var WebsiteURL: String {
            Bundle.main.object(forInfoDictionaryKey: "WebsiteURL") as! String
        }
        static var SupportEmail: String {
            Bundle.main.object(forInfoDictionaryKey: "SupportEmail") as! String
        }
        
        static var BundleIdentifier: String {
            Bundle.main.bundleIdentifier ?? "-"
        }
    }
    
    struct Fonts {
        static let nunito = "Nunito"
    }
    
    private init() {}
}
