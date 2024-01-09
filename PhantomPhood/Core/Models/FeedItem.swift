//
//  FeedItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

enum FeedItemActivityType: String, Decodable, CaseIterable {
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
    case user(CompactUser)
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

struct FeedItem: Identifiable, Decodable, Equatable {
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let user: CompactUser
    let place: CompactPlace?
    let activityType: FeedItemActivityType
    let resourceType: FeedItemResourceType
    let resource: FeedItemResource
    let privacyType: PrivacyType
    let createdAt: String
    let updatedAt: String
    var reactions: ReactionsObject
    let comments: [Comment]
    let commentsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, user, place, activityType, resourceType, resource, privacyType, createdAt, updatedAt, reactions, comments, commentsCount
    }
    
    // By Values
    init(id: String, user: CompactUser, place: CompactPlace?, activityType: FeedItemActivityType, resourceType: FeedItemResourceType, resource: FeedItemResource, privacyType: PrivacyType, createdAt: String, updatedAt: String, reactions: ReactionsObject, comments: [Comment], commentsCount: Int) {
        self.id = id
        self.user = user
        self.place = place
        self.activityType = activityType
        self.resourceType = resourceType
        self.resource = resource
        self.privacyType = privacyType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reactions = reactions
        self.comments = comments
        self.commentsCount = commentsCount
    }
    
    // From Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(CompactUser.self, forKey: .user)
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
            let value = try container.decode(CompactUser.self, forKey: .resource)
            resource = .user(value)
        }
        
        privacyType = try container.decode(PrivacyType.self, forKey: .privacyType)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        reactions = try container.decode(ReactionsObject.self, forKey: .reactions)
        reactions.total.sort { $0.count > $1.count }
        
        comments = try container.decode([Comment].self, forKey: .comments)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
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
