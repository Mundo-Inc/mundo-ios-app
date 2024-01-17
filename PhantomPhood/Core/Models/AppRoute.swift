//
//  AppRoute.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation
import MapKit

enum AppRoute: Hashable {
    case notifications
    case userActivity(id: String)
    
    // My Profile
    case settings
    case myConnections(initTab: UserConnectionsTab)
    
    // Place
    case place(id: String, action: PlaceAction? = nil)
    case placeMapPlace(mapPlace: MapPlace, action: PlaceAction? = nil)
    
    // User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(userId: UserIdEnum, activityType: ProfileActivitiesVM.FeedItemActivityType = .all)
    case userCheckins(userId: UserIdEnum)
    
    case placesList(listId: String)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .notifications:
            hasher.combine("notifications")
        case .userActivity(let id):
            hasher.combine("userActivity")
            hasher.combine(id)
            
            // My Profile
            
        case .settings:
            hasher.combine("settings")
        case .myConnections(initTab: let tab):
            hasher.combine("myConnections")
            hasher.combine(tab)
            
            // Place
            
        case .place(let id, let action):
            hasher.combine("place")
            hasher.combine(id)
            hasher.combine(action)
        case .placeMapPlace(let mapPlace, let action):
            hasher.combine("place")
            hasher.combine(mapPlace)
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
            
        case .placesList(let listId):
            hasher.combine("placesList")
            hasher.combine(listId)
        }
    }
}

enum PlaceAction: Hashable {
    case checkin
    case addReview
}

struct MapPlace: Hashable {
    let coordinate: CLLocationCoordinate2D
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

enum MyProfileActiveTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Achievements"
    case lists = "Lists"
}

enum UserConnectionsTab {
    case followers
    case followings
}
