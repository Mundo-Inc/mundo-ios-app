//
//  LeaderboardStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum LeaderboardStack: Hashable {
    
    // Common General
    case place(id: String, action: PlaceAction? = nil)
    // Common User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(userId: UserIdEnum, activityType: ProfileActivitiesVM.FeedItemActivityType = .all)
    case userCheckins(userId: UserIdEnum)
    
    func hash(into hasher: inout Hasher) {
        switch self {
            
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
