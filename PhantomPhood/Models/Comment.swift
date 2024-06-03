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
    let mentions: [UserMentions]?
    var likes: Int
    var liked: Bool
    var repliesCount: Int?
    var replies: [String]?
    
    // Used for showing replies
    var depth: [String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, createdAt, updatedAt, author, mentions, likes, liked, repliesCount, replies
    }
    
    /// For going deeper into the replies
    /// Used for displaying comments
    mutating func showReply(_ commentId: String) {
        guard commentId != id else { return }
        
        var currentDepth = self.depth ?? []
        currentDepth.append(commentId)
        depth = currentDepth
    }
    
    mutating func addReply(_ commentId: String) {
        repliesCount = (repliesCount ?? 0) + 1
        if replies == nil {
            replies = [commentId]
        } else {
            replies!.append(commentId)
        }
    }
    
    mutating func removeReply(_ commentId: String) {
        if let repliesCount {
            self.repliesCount = repliesCount - 1
        }
        if let replies {
            self.replies = replies.filter({ $0 != commentId })
        }
    }
    
    mutating func setLike(to status: Bool) {
        if status {
            if !liked {
                liked = true
                likes += 1
            }
        } else {
            if liked {
                liked = false
                likes -= 1
            }
        }
    }
}
