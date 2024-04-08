//
//  HomeMade.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/13/24.
//

import Foundation

struct HomeMade: Identifiable, Decodable {
    let id: String
    let content: String
    let media: [MediaItem]
    let user: UserEssentials
    let tags: [UserEssentials]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, media, user, tags, createdAt, updatedAt
    }
}
