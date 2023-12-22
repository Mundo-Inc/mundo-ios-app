//
//  User.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct User: Identifiable, Decodable {
    let _id: String
    let name: String
    let username: String
    let bio: String
    let coins: Int
    let verified: Bool
    let profileImage: String
    let progress: UserProgress
    
    var id: String {
        self._id
    }
}

struct UserProfile: Identifiable, Decodable {
    let _id: String
    let name: String
    let username: String
    let bio: String
    let coins: Int
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
    
    var id: String {
        self._id
    }
}

struct UserProgress: Codable {
    let xp: Int
    let level: Int
    let achievements: [UserAchievments]
}

struct UserAchievments: Codable, Identifiable {
    let _id: String
    let type: String
    let createdAt: String
    
    var id: String {
        self._id
    }
}

struct UserConnection: Identifiable, Decodable {
    let _id: String
    let user: User
    let createdAt: String
    
    var id: String {
        self._id
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
