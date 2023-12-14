//
//  HomeStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import MapKit

enum PlaceAction: Hashable {
    case checkin
    case addReview
}

enum HomeStack: Hashable {
    case notifications
    case userProfile(id: String)
    case place(id: String, action: PlaceAction? = nil)
    case placeMapPlace(mapPlace: MapPlace, action: PlaceAction? = nil)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    case userActivity(id: String)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .notifications:
            hasher.combine("notifications")
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        case .place(let id, let action):
            hasher.combine("place")
            hasher.combine(id)
            hasher.combine(action)
        case .placeMapPlace(let mapPlace, let action):
            hasher.combine("place")
            hasher.combine(mapPlace)
            hasher.combine(action)
        case .userConnections(let userId, let tab):
            hasher.combine("userConnections")
            hasher.combine(userId)
            hasher.combine(tab)
        case .userActivity(let id):
            hasher.combine("userActivity")
            hasher.combine(id)
        }
    }
}
