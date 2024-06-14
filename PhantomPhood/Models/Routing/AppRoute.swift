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
    case leaderboard
    case userActivity(id: String)
    
    // Actions
    case checkin(IdOrData<PlaceEssentials>, Event? = nil)
    case checkinMapPlace(MapPlace)
    case review(IdOrData<PlaceEssentials>)
    case reviewMapPlace(MapPlace)
    case report(item: ReportDM.ReportType)
    case homemadeContent
    
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
    
    // Conversation
    case conversation(sid: String, focusOnTextField: Bool)
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

enum UserConnectionsTab {
    case followers
    case followings
}
