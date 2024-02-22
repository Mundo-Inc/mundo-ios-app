//
//  UserEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct UserEssentials: Identifiable, Decodable {
    let id: String
    let name: String
    let username: String
    let verified: Bool
    let profileImage: URL?
    let progress: CompactUserProgress
    
    struct CompactUserProgress: Decodable {
        let level: Int
        let xp: Int
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, verified, profileImage, progress
    }
}

extension UserEssentials {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        verified = try container.decode(Bool.self, forKey: .verified)
        progress = try container.decode(CompactUserProgress.self, forKey: .progress)

        if let profileImageString = try container.decodeIfPresent(String.self, forKey: .profileImage), !profileImageString.isEmpty {
            profileImage = URL(string: profileImageString)
        } else {
            profileImage = nil
        }
    }
}

extension UserEssentials {
    init(userDetail: UserDetail) {
        self.id = userDetail.id
        self.name = userDetail.name
        self.username = userDetail.username
        self.verified = userDetail.verified
        self.profileImage = userDetail.profileImage
        self.progress = CompactUserProgress(level: userDetail.progress.level, xp: userDetail.progress.xp)
    }
}
