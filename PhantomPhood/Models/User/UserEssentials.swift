//
//  UserEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation
import SwiftUI
import CoreData

struct UserEssentials: Identifiable, Equatable, Decodable {
    static func == (lhs: UserEssentials, rhs: UserEssentials) -> Bool {
        lhs.id == rhs.id
    }
    
    static let colors: [Color] = [.yellow, .cyan, .orange, .purple, .pink, .red, .green, .mint, .teal, .indigo]
    
    let id: String
    let name: String
    let username: String
    let verified: Bool
    let isPrivate: Bool
    let profileImage: URL?
    let progress: CompactUserProgress
    var connectionStatus: ConnectionStatus?
    
    struct CompactUserProgress: Decodable {
        let level: Int
        let xp: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, verified, isPrivate, profileImage, progress, connectionStatus
    }
    
    var color: Color {
        let index = self.id.index(self.id.startIndex, offsetBy: 8)
        let subHex = String(self.id[..<index])
        guard let hexValue = UInt64(subHex, radix: 16) else {
            return Self.colors[0]
        }
        
        return Self.colors[Int(hexValue % 10)]
    }
    
    mutating func setConnectionStatus(following: FollowStatusEnum) {
        guard let connectionStatus else { return }
        self.connectionStatus = ConnectionStatus(followingStatus: following, followedByStatus: connectionStatus.followedByStatus)
    }
    
    mutating func setConnectionStatus(followedBy: FollowStatusEnum) {
        guard let connectionStatus else { return }
        self.connectionStatus = ConnectionStatus(followingStatus: connectionStatus.followingStatus, followedByStatus: followedBy)
    }
    
    mutating func setConnectionStatus(following: FollowStatusEnum, followedBy: FollowStatusEnum) {
        self.connectionStatus = ConnectionStatus(followingStatus: following, followedByStatus: followedBy)
    }
}

extension UserEssentials {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        verified = try container.decode(Bool.self, forKey: .verified)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        progress = try container.decode(CompactUserProgress.self, forKey: .progress)
        connectionStatus = try container.decodeIfPresent(ConnectionStatus.self, forKey: .connectionStatus)
        profileImage = try container.decodeURLIfPresent(forKey: .profileImage)
    }
}

extension UserEssentials {
    init(userDetail: UserDetail) {
        self.id = userDetail.id
        self.name = userDetail.name
        self.username = userDetail.username
        self.verified = userDetail.verified
        self.isPrivate = userDetail.isPrivate
        self.profileImage = userDetail.profileImage
        self.progress = CompactUserProgress(level: userDetail.progress.level, xp: userDetail.progress.xp)
        self.connectionStatus = userDetail.connectionStatus
    }
}

extension UserEssentials {
    init(_ entity: UserEntity) {
        self.id = entity.id ?? ""
        self.name = entity.name ?? ""
        self.username = entity.username ?? ""
        self.verified = entity.verified
        self.isPrivate = entity.isPrivate
        self.profileImage = entity.profileImage != nil ? URL(string: entity.profileImage!) : nil
        self.progress = .init(level: Int(entity.level), xp: Int(entity.xp))
        self.connectionStatus = nil
    }
    
    init(entity: UserEntity) throws {
        guard let id = entity.id, let name = entity.name, let username = entity.username else {
            throw CancellationError()
        }
        
        self.id = id
        self.name = name
        self.username = username
        self.verified = entity.verified
        self.isPrivate = entity.isPrivate
        self.profileImage = entity.profileImage != nil ? URL(string: entity.profileImage!) : nil
        self.progress = .init(level: Int(entity.level), xp: Int(entity.xp))
        self.connectionStatus = nil
    }
    
    func createUserEntity(context: NSManagedObjectContext) -> UserEntity {
        var userEntity: UserEntity!
        context.performAndWait {
            userEntity = UserEntity(context: context)
            userEntity.id = self.id
            userEntity.name = self.name
            userEntity.username = self.username
            userEntity.verified = self.verified
            userEntity.isPrivate = self.isPrivate
            userEntity.profileImage = self.profileImage?.absoluteString
            userEntity.level = Int16(self.progress.level)
            userEntity.xp = Int16(self.progress.xp)
            userEntity.savedAt = .now
            
            do {
                try context.obtainPermanentIDs(for: [userEntity])
            } catch {
                presentErrorToast(error, debug: "Error obtaining a permanent ID for userEntity", silent: true)
            }
        }
        return userEntity
    }
}

