//
//  MapStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum MapStack: Hashable {
    case userProfile(id: String)
    case place(id: String, action: PlaceAction? = nil)
    case userConnections(userId: String, initTab: UserConnectionsTab)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        case .place(let id, let action):
            hasher.combine("place")
            hasher.combine(id)
            hasher.combine(action)
        case .userConnections(let userId, let tab):
            hasher.combine("userConnections")
            hasher.combine(userId)
            hasher.combine(tab)
        }
    }
}
