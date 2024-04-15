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
    let prevLevelXp: Int
    let followersCount: Int
    let followingCount: Int
    let reviewsCount: Int
    let totalCheckins: Int
    let rank: Int
    let verified: Bool
    let profileImage: URL?
    let progress: UserProgress
    var connectionStatus: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, bio, remainingXp, prevLevelXp, verified, profileImage, followersCount, followingCount, reviewsCount, totalCheckins, rank, progress, connectionStatus
    }
    
    var levelProgress: Double {
        Double(self.progress.xp - self.prevLevelXp) / Double(self.progress.xp + self.remainingXp - self.prevLevelXp)
    }
    
    mutating func setFollowedByUserStatus(_ status: Bool) {
        self.connectionStatus = ConnectionStatus(followedByUser: status, followsUser: connectionStatus.followsUser)
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
        connectionStatus = try container.decode(ConnectionStatus.self, forKey: .connectionStatus)
        progress = try container.decode(UserProgress.self, forKey: .progress)
        
        if let profileImageString = try container.decodeIfPresent(String.self, forKey: .profileImage), !profileImageString.isEmpty {
            profileImage = URL(string: profileImageString)
        } else {
            profileImage = nil
        }
    }
}

struct ConnectionStatus: Decodable {
    let followedByUser: Bool
    let followsUser: Bool
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
