//
//  UserDetail.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserDetail: Identifiable, Decodable {
    let id: String
    let name: String
    let username: String
    let bio: String
    let remainingXp: Int
    let verified: Bool
    let profileImage: String
    let isFollower: Bool
    let isFollowing: Bool
    let followersCount: Int
    let followingCount: Int
    let reviewsCount: Int
    let totalCheckins: Int
    let rank: Int
    let progress: UserProgress
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, bio, remainingXp, verified, profileImage, isFollower, isFollowing, followersCount, followingCount, reviewsCount, totalCheckins, rank, progress
    }
}

struct UserProgress: Codable {
    let xp: Int
    let level: Int
    let achievements: [UserAchievments]
    
    struct UserAchievments: Codable, Identifiable {
        let id: AchievementsEnum
        let count: Int
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id = "type"
            case count, createdAt
        }
    }
}

enum UserIdEnum: Hashable, Equatable {
    case currentUser
    case withId(String)
    
    var id: String? {
        switch self {
        case .currentUser:
            return nil
        case .withId(let id):
            return id
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
