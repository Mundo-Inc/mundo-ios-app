//
//  Notification.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

struct NotificationResource {
    let _id: String
    let date: String
    let type: NotificationResourceType
    
    var id: String {
        self._id
    }
}

struct Notification: Decodable, Identifiable {
    let _id: String
    let user: CompactUser
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

    var id: String {
        self._id
    }

    var isKnownType: Bool {
        NotificationType.allCases.map { $0.rawValue }.contains(self.type)
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
