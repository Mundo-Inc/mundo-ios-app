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
    let bio: String?
    let remainingXp: Int
    let prevLevelXp: Int
    let followersCount: Int
    let followingCount: Int
    let reviewsCount: Int
    let totalCheckins: Int
    let rank: Int
    let verified: Bool
    let profileImage: URL?
    let progress: UserProgress
    let isPrivate: Bool
    var connectionStatus: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, bio, remainingXp, prevLevelXp, verified, profileImage, followersCount, followingCount, reviewsCount, totalCheckins, rank, progress, isPrivate, connectionStatus
    }
    
    var levelProgress: Double {
        Double(self.progress.xp - self.prevLevelXp) / Double(self.progress.xp + self.remainingXp - self.prevLevelXp)
    }
    
    mutating func setConnectionStatus(following: FollowStatusEnum) {
        self.connectionStatus = ConnectionStatus(followingStatus: following, followedByStatus: connectionStatus.followedByStatus)
    }
    
    mutating func setConnectionStatus(followedBy: FollowStatusEnum) {
        self.connectionStatus = ConnectionStatus(followingStatus: connectionStatus.followingStatus, followedByStatus: followedBy)
    }
    
    mutating func setConnectionStatus(following: FollowStatusEnum, followedBy: FollowStatusEnum) {
        self.connectionStatus = ConnectionStatus(followingStatus: following, followedByStatus: followedBy)
    }
    
    var essentials: UserEssentials {
        UserEssentials(userDetail: self)
    }
}

extension UserDetail {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decodeOptionalString(forKey: .bio)
        remainingXp = try container.decode(Int.self, forKey: .remainingXp)
        prevLevelXp = try container.decode(Int.self, forKey: .prevLevelXp)
        followersCount = try container.decode(Int.self, forKey: .followersCount)
        followingCount = try container.decode(Int.self, forKey: .followingCount)
        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        totalCheckins = try container.decode(Int.self, forKey: .totalCheckins)
        rank = try container.decode(Int.self, forKey: .rank)
        verified = try container.decode(Bool.self, forKey: .verified)
        connectionStatus = try container.decode(ConnectionStatus.self, forKey: .connectionStatus)
        progress = try container.decode(UserProgress.self, forKey: .progress)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        profileImage = try container.decodeURLIfPresent(forKey: .profileImage)
    }
}

struct ConnectionStatus: Decodable {
    /// The status of the current user following the target user
    let followingStatus: FollowStatusEnum
    
    /// The status of the target user following the current user
    let followedByStatus: FollowStatusEnum
}

enum FollowStatusEnum: String, Decodable, CaseIterable {
    case following = "following"
    case notFollowing = "notfollowing"
    case requested = "requested"
}

extension FollowStatusEnum {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        
        if let status = FollowStatusEnum(rawValue: rawValue) {
            self = status
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid value for FollowStatusEnum"))
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
