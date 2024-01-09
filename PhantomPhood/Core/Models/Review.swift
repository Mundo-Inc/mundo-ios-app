//
//  Review.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct ReviewScores: Decodable {
    let overall: Double?
    let drinkQuality: Double?
    let foodQuality: Double?
    let atmosphere: Double?
    let service: Double?
    let value: Double?
}

struct PlaceReview: Identifiable, Decodable {
    let _id: String
    let scores: ReviewScores?
    let content: String
    let images: [Media]
    let videos: [Media]
    let tags: [String]?
    let recommend: Bool?
    let language: String?
    let createdAt: String
    let updatedAt: String
    let userActivityId: String?
    let writer: CompactUser
    let comments: [Comment]
    var reactions: ReactionsObject
    
    var id: String {
        self._id
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


struct FeedReview: Identifiable, Decodable {
    let _id: String
    let scores: ReviewScores
    let content: String
    let images: [Media]
    let videos: [Media]
    let tags: [String]?
    let recommend: Bool?
    let language: String?
    let createdAt: String
    let updatedAt: String
    let userActivityId: String?
    let writer: CompactUser
    
    var id: String {
        self._id
    }
}
