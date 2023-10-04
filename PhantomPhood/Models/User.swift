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
    let xp: Int
    let level: Int
    let verified: Bool
    let profileImage: String?
    
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
    let xp: Int
    let remainingXp: Int
    let level: Int
    let verified: Bool
    let profileImage: String?
    let isFollower: Bool
    let isFollowing: Bool
    let followersCount: Int
    let followingCount: Int
    let reviewsCount: Int
    let rank: Int
    
    var id: String {
        self._id
    }
}
