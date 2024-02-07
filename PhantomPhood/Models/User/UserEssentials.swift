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
    let profileImage: String
    let progress: CompactUserProgress
    
    struct CompactUserProgress: Decodable {
        let level: Int
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, verified, profileImage, progress
    }
}

extension UserEssentials {
    init(userDetail: UserDetail) {
        self.id = userDetail.id
        self.name = userDetail.name
        self.username = userDetail.username
        self.verified = userDetail.verified
        self.profileImage = userDetail.profileImage
        self.progress = CompactUserProgress(level: userDetail.progress.level)
    }
}
