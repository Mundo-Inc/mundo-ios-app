//
//  Tab.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case rewardsHub = "RewardsHub"
    case myProfile = "MyProfile"
    
    var imageName: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .rewardsHub: return "RewardsHub"
        case .myProfile: return "Profile"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .rewardsHub: return "Rewards Hub"
        case .myProfile: return "Profile"
        }
    }
    
    static func convert(from: String) -> Self? {
        return Tab.allCases.first { tab in
            tab.rawValue.lowercased() == from.lowercased()
        }
    }
}
