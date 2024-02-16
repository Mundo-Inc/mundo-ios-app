//
//  Comment.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct UserMentions: Decodable {
    let user: String
    let username: String
}

struct Comment: Decodable, Identifiable {
    let id: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let author: UserEssentials
    let likes: Int
    let liked: Bool
    let mentions: [UserMentions]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, createdAt, updatedAt, author, likes, liked, mentions
    }
}
