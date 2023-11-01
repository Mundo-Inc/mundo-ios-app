//
//  MyProfileStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum MyProfileStack: Hashable {
    case settings
    case userProfile(id: String)
    case place(id: String, action: PlaceAction? = nil)
    case myConnections(initTab: UserConnectionsTab)
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings:
            hasher.combine("settings")
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        case .place(let id, let action):
            hasher.combine("place")
            hasher.combine(id)
            hasher.combine(action)
        case .myConnections(initTab: let tab):
            hasher.combine("myConnections")
            hasher.combine(tab)
        }
    }
}

enum MyProfileActiveTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case activity = "Activity"
    case checkins = "Checkins"
}

enum UserConnectionsTab {
    case followers
    case followings
}
