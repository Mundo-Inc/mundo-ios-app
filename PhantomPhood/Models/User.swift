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
