//
//  UserDetail.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserDetail: Identifiable, Decodable {
    let id,
        name,
        username,
        bio: String
    let remainingXp,
        prevLevelXp,
        followersCount,
        followingCount,
        reviewsCount,
        totalCheckins,
        rank: Int
    let verified,
        isFollower,
        isFollowing: Bool
    let profileImage: URL?
    let progress: UserProgress
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, bio, remainingXp, prevLevelXp, verified, profileImage, isFollower, isFollowing, followersCount, followingCount, reviewsCount, totalCheckins, rank, progress
    }
    
    var levelProgress: Double {
        Double(self.progress.xp - self.prevLevelXp) / Double(self.progress.xp + self.remainingXp - self.prevLevelXp)
    }
}

extension UserDetail {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decode(String.self, forKey: .bio)
        remainingXp = try container.decode(Int.self, forKey: .remainingXp)
        prevLevelXp = try container.decode(Int.self, forKey: .prevLevelXp)
        followersCount = try container.decode(Int.self, forKey: .followersCount)
        followingCount = try container.decode(Int.self, forKey: .followingCount)
        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        totalCheckins = try container.decode(Int.self, forKey: .totalCheckins)
        rank = try container.decode(Int.self, forKey: .rank)
        verified = try container.decode(Bool.self, forKey: .verified)
        isFollower = try container.decode(Bool.self, forKey: .isFollower)
        isFollowing = try container.decode(Bool.self, forKey: .isFollowing)
        progress = try container.decode(UserProgress.self, forKey: .progress)
        
        if let profileImageString = try container.decodeIfPresent(String.self, forKey: .profileImage), !profileImageString.isEmpty {
            profileImage = URL(string: profileImageString)
        } else {
            profileImage = nil
        }
    }
}

struct UserProgress: Codable {
    let xp: Int
    let level: Int
    let achievements: [UserAchievments]
    
    struct UserAchievments: Codable, Identifiable {
        let id: AchievementsEnum
        let count: Int
        let createdAt: Date
        
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
