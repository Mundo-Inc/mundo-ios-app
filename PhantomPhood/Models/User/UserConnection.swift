//
//  UserConnection.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserConnection: Identifiable, Decodable {
    let id: String
    let user: UserOverview
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, createdAt
    }
}
