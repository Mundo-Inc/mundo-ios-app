//
//  Tab.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "Home"
    case map = "Map"
    case leaderboard = "Leaderboard"
    case myProfile = "MyProfile"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .map: return "globe.americas.fill"
        case .leaderboard: return "crown"
        case .myProfile: return "person.crop.circle"
        }
    }
    
    static func convert(from: String) -> Self? {
        return Tab.allCases.first { tab in
            tab.rawValue.lowercased() == from.lowercased()
        }
    }
}
