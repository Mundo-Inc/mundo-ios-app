//
//  FollowRequest.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/13/24.
//

import Foundation

struct FollowRequest: Identifiable, Decodable {
    let id: String
    var user: UserEssentials
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, createdAt
    }
}
