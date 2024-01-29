//
//  Notification.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct Notification: Decodable, Identifiable {
    let id: String
    let user: UserEssentials
    let type: String
    var readAt: String?
    let sent: Bool
    let failReason: String?
    let importance: Int
    let batchCount: Int
    let content: String
    let createdAt: String
    let updatedAt: String
    let image: String?
    let subtitle: String?
    let title: String?
    let activity: String?

    var isKnownType: Bool {
        NotificationType.allCases.map { $0.rawValue }.contains(self.type)
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, type, readAt, sent, failReason, importance, batchCount, content, createdAt, updatedAt, image, subtitle, title, activity
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
}

enum NotificationResourceType: String, Decodable {
    case comment = "Comment"
    case user = "User"
    case review = "Review"
    case checkin = "CheckIn"
    case follow = "Follow"
    case reaction = "Reaction"
}
