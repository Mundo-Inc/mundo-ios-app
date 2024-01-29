//
//  UserOverview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct UserOverview: Identifiable, Decodable {
    let id: String
    let name: String
    let username: String
    let bio: String
    let verified: Bool
    let profileImage: String
    let progress: UserProgress
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, bio, verified, profileImage, progress
    }
}

extension UserOverview {
    init(userDetail: UserDetail) {
        self.id = userDetail.id
        self.name = userDetail.name
        self.username = userDetail.username
        self.bio = userDetail.bio
        self.verified = userDetail.verified
        self.profileImage = userDetail.profileImage
        self.progress = userDetail.progress
    }
}