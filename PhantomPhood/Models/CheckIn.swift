//
//  Checkin.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct CheckIn: Identifiable, Decodable {
    let id: String
    let createdAt: Date
    let user: UserEssentials
    let place: PlaceEssentials
    let media: [MediaItem]?
    let tags: [UserEssentials]?
    let caption: String?
    let userActivityId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, user, place, media, tags, caption, userActivityId
    }
}

struct FeedCheckin: Identifiable, Decodable {
    let id: String
    let createdAt: Date
    let user: UserEssentials
    let place: PlaceEssentials
    let media: [MediaItem]?
    let tags: [UserEssentials]?
    let caption: String?
    let userActivityId: String?
    let totalCheckins: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, user, place, totalCheckins, media, tags, caption, userActivityId
    }
}
