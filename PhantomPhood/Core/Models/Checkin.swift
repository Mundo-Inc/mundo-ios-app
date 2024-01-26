//
//  Checkin.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct Checkin: Identifiable, Decodable {
    let id: String
    let createdAt: String
    let user: UserEssentials
    let place: PlaceEssentials
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, user, place
    }
}

struct FeedCheckin: Identifiable, Decodable {
    let id: String
    let createdAt: String
    let user: UserEssentials
    let place: PlaceEssentials
    let totalCheckins: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, user, place, totalCheckins
    }
}
