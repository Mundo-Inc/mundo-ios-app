//
//  UserEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation
import SwiftUI
import CoreData

struct UserEssentials: Identifiable, Decodable {
    static let colors: [Color] = [.yellow, .cyan, .orange, .purple, .pink, .red, .green, .mint, .teal, .indigo]
    
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
    
    var color: Color {
        let index = self.id.index(self.id.startIndex, offsetBy: 8)
        let subHex = String(self.id[..<index])
        guard let hexValue = UInt64(subHex, radix: 16) else {
            return Self.colors[0]
        }
        
        return Self.colors[Int(hexValue % 10)]
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

extension UserEssentials {
    init(_ entity: UserEntity) {
        id = entity.id!
        name = entity.name!
        username = entity.username!
        verified = entity.verified
        profileImage = entity.profileImage != nil ? URL(string: entity.profileImage!) : nil
        progress = .init(level: Int(entity.level), xp: Int(entity.xp))
    }
    
    func createUserEntity(context: NSManagedObjectContext) -> UserEntity {
        let userEntity = UserEntity(context: context)
        userEntity.id = self.id
        userEntity.name = self.name
        userEntity.username = self.username
        userEntity.verified = self.verified
        userEntity.profileImage = self.profileImage?.absoluteString
        userEntity.level = Int16(self.progress.level)
        userEntity.xp = Int16(self.progress.xp)
        userEntity.savedAt = .now
        
        do {
            try context.obtainPermanentIDs(for: [userEntity])
        } catch {
            print("Error obtaining a permanent ID for userEntity: \(error)")
        }
        
        return userEntity
    }
}

