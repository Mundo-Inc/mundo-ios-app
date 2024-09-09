//
//  UserEntity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/4/24.
//

import Foundation
import CoreData

extension UserEntity {
    static func fetchRequest(forId id: String) -> NSFetchRequest<UserEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forIds ids: Set<String>) -> NSFetchRequest<UserEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return request
    }
    
    func updateInfo(with user: UserEssentials) {
        self.id = user.id
        self.name = user.name
        self.username = user.username
        self.verified = user.verified
        self.isPrivate = user.isPrivate
        self.profileImage = user.profileImage?.absoluteString
        self.level = Int16(user.progress.level)
        self.xp = Int16(user.progress.xp)
        self.savedAt = Date()
    }
}
