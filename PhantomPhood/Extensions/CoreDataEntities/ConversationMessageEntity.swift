//
//  ConversationMessageEntity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/6/24.
//

import Foundation
import CoreData

extension ConversationMessageEntity {
    static func fetchRequest(forId id: String) -> NSFetchRequest<ConversationMessageEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forIds ids: Set<String>) -> NSFetchRequest<ConversationMessageEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return request
    }
}
