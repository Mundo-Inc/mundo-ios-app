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
    let reactions: ReactionsObject
    
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
