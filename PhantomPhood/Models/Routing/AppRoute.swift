//
//  AppRoute.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation
import MapKit

enum AppRoute: Hashable {
    case inbox
    case conversation(_ args: ConversationArgs)
    case leaderboard
    case userActivity(id: String)
    
    // Actions
    case checkIn(PlaceIdentifier, Event? = nil)
    case report(item: ReportDM.ReportType)
    
    // My Profile
    case settings
    case paymentsSetting
    case myConnections(initTab: UserConnectionsTab)
    case requests
    case myActivities(vm: MyProfileVM, selected: FeedItem? = nil)
    
    // Place
    case place(id: String, action: PlaceAction? = nil)
    case placeMapPlace(mapPlace: MapPlace, action: PlaceAction? = nil)
    
    // Event
    case event(IdOrData<Event>)
    
    // User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(vm: UserProfileVM, selected: FeedItem? = nil)
    case userCheckins(userId: UserIdEnum)
    
    case placesList(listId: String)
    
    enum ConversationArgs: Hashable {
        case user(IdOrData<UserEssentials>)
        case id(String)
    }
}

enum PlaceAction: Hashable {
    case checkIn
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

enum UserConnectionsTab {
    case followers
    case followings
}
