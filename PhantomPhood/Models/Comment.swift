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
    let _id: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let author: User
    let likes: Int
    let liked: Bool
    let mentions: [UserMentions]?

    var id: String {
        self._id
    }
}

