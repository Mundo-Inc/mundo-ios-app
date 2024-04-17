//
//  Notification.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct Notification: Decodable, Identifiable {
    let id: String
    let user: UserEssentials?
    let type: String
    let sent: Bool
    let importance: Int
    let batchCount: Int
    let title: String?
    let content: String?
    let createdAt: Date
    let updatedAt: Date
    let image: URL?
    let activity: String?
    var readAt: Date?
    let failReason: String?

    var isKnownType: Bool {
        NotificationType.allCases.map { $0.rawValue }.contains(self.type)
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, type, sent, importance, batchCount, title, content, createdAt, updatedAt, image, activity, readAt, failReason
    }
}

extension Notification {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.user = try container.decodeIfPresent(UserEssentials.self, forKey: .user)
        self.type = try container.decode(String.self, forKey: .type)
        self.sent = try container.decode(Bool.self, forKey: .sent)
        self.importance = try container.decode(Int.self, forKey: .importance)
        self.batchCount = try container.decode(Int.self, forKey: .batchCount)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.activity = try container.decodeIfPresent(String.self, forKey: .activity)
        self.readAt = try container.decodeIfPresent(Date.self, forKey: .readAt)
        self.failReason = try container.decodeIfPresent(String.self, forKey: .failReason)
        
        if let title = try container.decodeIfPresent(String.self, forKey: .title), !title.isEmpty {
            self.title = title
        } else {
            self.title = nil
        }
        
        if let content = try container.decodeIfPresent(String.self, forKey: .content), !content.isEmpty {
            self.content = content
        } else {
            self.content = nil
        }
        
        if let imageString = try container.decodeIfPresent(String.self, forKey: .image), !imageString.isEmpty {
            self.image = URL(string: imageString)
        } else {
            self.image = nil
        }
    }
}

enum NotificationType: String, Decodable, CaseIterable {
    case reaction = "REACTION"
    case comment = "COMMENT"
    case follow = "FOLLOW"
    case comment_mention = "COMMENT_MENTION"
    case review_mention = "REVIEW_MENTION"
    case following_checkin = "FOLLOWING_CHECKIN"
    case following_review = "FOLLOWING_REVIEW"
    case xp = "XP"
    case level_up = "LEVEL_UP"
    case referralReward = "REFERRAL_REWARD"
}

enum NotificationResourceType: String, Decodable {
    case comment = "Comment"
    case user = "User"
    case review = "Review"
    case checkin = "CheckIn"
    case follow = "Follow"
    case reaction = "Reaction"
}
