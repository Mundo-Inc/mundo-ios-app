//
//  ConversationParticipantEntity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/6/24.
//

import Foundation
import CoreData

extension ConversationParticipantEntity {
    static func fetchRequest(userId: String, conversationId: String) -> NSFetchRequest<ConversationParticipantEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(conversationId)-\(userId)")
        return request
    }
    
    static func fetchRequest(conversationId: String) -> NSFetchRequest<ConversationParticipantEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id == %@", conversationId)
        return request
    }
    
    static func fetchRequest(conversationIds: Set<String>) -> NSFetchRequest<ConversationParticipantEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id IN %@", conversationIds)
        return request
    }
}
