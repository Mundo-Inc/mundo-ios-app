//
//  MapStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import MapKit

enum MapStack: Hashable {
    case placeMapPlace(mapPlace: MapPlace, action: PlaceAction? = nil)
    
    // Common General
    case place(id: String, action: PlaceAction? = nil)
    // Common User
    case userProfile(userId: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivities(userId: UserIdEnum, activityType: ProfileActivitiesVM.FeedItemActivityType = .all)
    case userCheckins(userId: UserIdEnum)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .placeMapPlace(let mapPlace, let action):
            hasher.combine("place")
            hasher.combine(mapPlace)
            hasher.combine(action)
            
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


struct MapPlace: Hashable {
    let coordinate: CLLocationCoordinate2D
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
