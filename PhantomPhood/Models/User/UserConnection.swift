//
//  UserConnection.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserConnection: Identifiable, Decodable {
    static let dummy = UserConnection(id: "", user: .init(id: "", name: "Dwayne", username: "username", verified: false, isPrivate: false, profileImage: nil, progress: .init(level: 50, xp: 3000), connectionStatus: nil), createdAt: .now)
    
    let id: String
    let user: UserEssentials
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, createdAt
    }
}
