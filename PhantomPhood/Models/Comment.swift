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

struct Comment: Decodable, Identifiable, Hashable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let author: UserEssentials
    var likes: Int
    var liked: Bool
    let mentions: [UserMentions]?
    var repliesCount: Int?
    var replies: [String]?
    
    // Used for showing replies
    var depth: [String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, createdAt, updatedAt, author, likes, liked, mentions, repliesCount, replies
    }
    
    mutating func showReply(_ commentId: String) {
        var currentDepth = self.depth ?? []
        currentDepth.append(commentId)
        depth = currentDepth
    }
}
