//
//  Review.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

/*
 scores: 1,
 content: 1,
 images: 1,
 videos: 1,
 tags: 1,
 language: 1,
 createdAt: 1,
 updatedAt: 1,
 userActivityId: 1,
 writer: { $arrayElemAt: ["$writer", 0] },
 reactions: {
   $arrayElemAt: ["$reactions", 0],
 },
 comments: 1,
 */

struct ReviewScores: Decodable {
    let overall: Double?
    let drinkQuality: Double?
    let foodQuality: Double?
    let atmosphere: Double?
    let service: Double?
    let value: Double?
}

struct Review: Identifiable, Decodable {
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
    let writer: User
    let comments: [Comment]
    let reactions: [Reaction]
    
    var id: String {
        self._id
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
    let writer: User
    
    var id: String {
        self._id
    }
}
