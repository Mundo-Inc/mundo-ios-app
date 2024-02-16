//
//  PlaceReview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct PlaceReview: Identifiable, Decodable {
    let id: String
    let scores: ReviewScores?
    let content: String
    let images: [Media]
    let videos: [Media]
    let tags: [String]?
    let recommend: Bool?
    let language: String?
    let createdAt: Date
    let updatedAt: Date
    let userActivityId: String?
    let writer: UserEssentials
    let comments: [Comment]
    var reactions: ReactionsObject
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case scores, content, images, videos, tags, recommend, language, createdAt, updatedAt, userActivityId, writer, comments, reactions
    }
    
    mutating func addReaction(_ userReaction: UserReaction) {
        var newReactions = self.reactions
        
        // Check if user has already reacted
        if let index = newReactions.user.firstIndex(where: { $0.id == userReaction.id }) {
            newReactions.user[index] = userReaction
        } else {
            newReactions.user.append(userReaction)
        }
        
        // Check if reaction already exists
        if let index = newReactions.total.firstIndex(where: { $0.reaction == userReaction.reaction }) {
            newReactions.total[index] = Reaction(reaction: userReaction.reaction, type: .emoji, count: newReactions.total[index].count + 1)
        } else {
            newReactions.total.append(Reaction(reaction: userReaction.reaction, type: .emoji, count: 1))
        }
        
        self.reactions = newReactions
    }
    
    mutating func removeReaction(_ userReaction: UserReaction) {
        var newReactions = self.reactions
        
        if let index = newReactions.user.firstIndex(where: { $0.id == userReaction.id }) {
            newReactions.user.remove(at: index)
        }
        
        if let index = newReactions.total.firstIndex(where: { $0.reaction == userReaction.reaction }) {
            newReactions.total[index] = Reaction(reaction: userReaction.reaction, type: .emoji, count: newReactions.total[index].count - 1)
        }
        
        self.reactions = newReactions
    }
}
