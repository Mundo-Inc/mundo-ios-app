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
    let images: [MediaItem]?
    let videos: [MediaItem]?
    let media: [MediaItem]?
    let tags: [String]?
    let recommend: Bool?
    let language: String?
    let createdAt: Date
    let updatedAt: Date
    let userActivityId: String?
    let writer: UserEssentials
    
    /// Temporary (for migrating from images/videos to media)
    var medias: [MediaItem] {
        var items: [MediaItem] = []
        if let media {
            return media
        }
        if let videos {
            items.append(contentsOf: videos)
        }
        if let images {
            items.append(contentsOf: images)
        }
        return items
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case scores, content, images, videos, media, tags, recommend, language, createdAt, updatedAt, userActivityId, writer
    }
}
