//
//  LeaderboardStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum LeaderboardStack: Hashable {
    case userProfile(id: String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        }
    }
}
