//
//  FeedItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

enum FeedItemActivityType: String, Decodable {
    case newCheckin = "NEW_CHECKIN"
    case newReview = "NEW_REVIEW"
    case newRecommend = "NEW_RECOMMEND"
    case addPlace = "ADD_PLACE"
    case gotBadge = "GOT_BADGE"
    case levelUp = "LEVEL_UP"
    case following = "FOLLOWING"
}

enum FeedItemResourceType: String, Decodable {
    case place = "Place"
    case review = "Review"
    case checkin = "Checkin"
    case user = "User"
//    case reaction = "Reaction"
//    case achievement = "Achievement"
}

enum FeedItemResource: Decodable {
    case place(CompactPlace)
    case review(FeedReview)
    case checkin(FeedCheckin)
    case user(User)
//    case reaction
//    case achievement
}

enum PrivacyType: String, Decodable {
    case PUBLIC = "PUBLIC"
    case PRIVATE = "PRIVATE"
}

struct ReactionsObject: Decodable {
    var total: [Reaction]
    var user: [UserReaction]
}

struct FeedItem: Identifiable, Decodable {
    let id: String
    let user: User
    let place: CompactPlace?
    let activityType: FeedItemActivityType
    let resourceType: FeedItemResourceType
    let resource: FeedItemResource
    let privacyType: PrivacyType
    let createdAt: String
    let updatedAt: String
    let score: Double
    let weight: Int
    let reactions: ReactionsObject
    let comments: [Comment]
    
    
    enum CodingKeys: String, CodingKey {
        case id, user, place, activityType, resourceType, resource, privacyType, createdAt, updatedAt, score, weight, reactions, comments
    }
    
    // By Values
    init(id: String, user: User, place: CompactPlace?, activityType: FeedItemActivityType, resourceType: FeedItemResourceType, resource: FeedItemResource, privacyType: PrivacyType, createdAt: String, updatedAt: String, score: Double, weight: Int, reactions: ReactionsObject, comments: [Comment]) {
        self.id = id
        self.user = user
        self.place = place
        self.activityType = activityType
        self.resourceType = resourceType
        self.resource = resource
        self.privacyType = privacyType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.score = score
        self.weight = weight
        self.reactions = reactions
        self.comments = comments
    }
    
    // From Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(User.self, forKey: .user)
        place = try container.decodeIfPresent(CompactPlace.self, forKey: .place)
        activityType = try container.decode(FeedItemActivityType.self, forKey: .activityType)
        resourceType = try container.decode(FeedItemResourceType.self, forKey: .resourceType)
        
        switch resourceType {
        case .place:
            let value = try container.decode(CompactPlace.self, forKey: .resource)
            resource = .place(value)
        case .review:
            let value = try container.decode(FeedReview.self, forKey: .resource)
            resource = .review(value)
        case .checkin:
            let value = try container.decode(FeedCheckin.self, forKey: .resource)
            resource = .checkin(value)
        case .user:
            let value = try container.decode(User.self, forKey: .resource)
            resource = .user(value)
        }
        
        privacyType = try container.decode(PrivacyType.self, forKey: .privacyType)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        score = try container.decode(Double.self, forKey: .score)
        weight = try container.decode(Int.self, forKey: .weight)
        reactions = try container.decode(ReactionsObject.self, forKey: .reactions)
        comments = try container.decode([Comment].self, forKey: .comments)
    }
}
