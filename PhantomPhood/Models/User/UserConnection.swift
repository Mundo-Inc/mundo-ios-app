//
//  UserConnection.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserConnection: Identifiable, Decodable {
    static let dummy = UserConnection(id: "", user: .init(id: "", name: "Name", username: "username", verified: false, profileImage: "", progress: .init(level: 50)), createdAt: "")
    
    let id: String
    let user: UserEssentials
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, createdAt
    }
}
