//
//  FeedReview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct FeedReview: Identifiable, Decodable {
    let id: String
    let scores: ReviewScores
    let content: String
    let media: [MediaItem]?
    let tags: [String]?
    let recommend: Bool?
    let language: String?
    let createdAt: Date
    let updatedAt: Date
    let userActivityId: String?
    let writer: UserEssentials
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case scores, content, media, tags, recommend, language, createdAt, updatedAt, userActivityId, writer
    }
}
