//
//  LeaderboardStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum LeaderboardStack: Hashable {
    case userProfile(id: String)
    case userConnections(userId: String, initTab: UserConnectionsTab)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        case .userConnections(let userId, let tab):
            hasher.combine("userConnections")
            hasher.combine(userId)
            hasher.combine(tab)
        }
    }
}
