//
//  MyProfileStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum MyProfileStack: Hashable {
    case settings
    case myConnections(initTab: UserConnectionsTab)
    
    // Common General
    case place(id: String, action: PlaceAction? = nil)
    // Common User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(userId: UserIdEnum, activityType: ProfileActivitiesVM.FeedItemActivityType = .all)
    case userCheckins(userId: UserIdEnum)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings:
            hasher.combine("settings")
        case .myConnections(initTab: let tab):
            hasher.combine("myConnections")
            hasher.combine(tab)
            
            // Common
            
        case .place(let id, let action):
            hasher.combine("place")
            hasher.combine(id)
            hasher.combine(action)
        case .userProfile(let userId):
            hasher.combine("userProfile")
            hasher.combine(userId)
        case .userConnections(let userId, let tab):
            hasher.combine("userConnections")
            hasher.combine(userId)
            hasher.combine(tab)
        case .userActivities(let userId, let activityType):
            hasher.combine("userActivities")
            hasher.combine(userId)
            hasher.combine(activityType)
        case .userCheckins(let userId):
            hasher.combine("userCheckins")
            hasher.combine(userId)
        }
    }
}

enum MyProfileActiveTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case lists = "Lists"
}

enum UserConnectionsTab {
    case followers
    case followings
}
