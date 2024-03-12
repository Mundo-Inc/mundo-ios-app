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
    case leaderboard
    case userActivity(id: String)
    
    // Actions
    case checkin(IdOrData<PlaceEssentials>, Event? = nil)
    case checkinMapPlace(MapPlace)
    case review(IdOrData<PlaceEssentials>)
    case reviewMapPlace(MapPlace)
    case report(id: String, type: ReportDM.ReportType)
    
    // My Profile
    case settings
    case myConnections(initTab: UserConnectionsTab)
    
    // Place
    case place(id: String, action: PlaceAction? = nil)
    case placeMapPlace(mapPlace: MapPlace, action: PlaceAction? = nil)
    
    // Event
    case event(IdOrData<Event>)
    
    // User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(userId: UserIdEnum, activityType: FeedItemActivityType = .all)
    case userCheckins(userId: UserIdEnum)
    
    case placesList(listId: String)
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
