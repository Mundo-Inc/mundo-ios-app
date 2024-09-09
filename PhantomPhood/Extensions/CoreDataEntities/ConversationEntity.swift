//
//  ConversationEntity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/6/24.
//

import Foundation
import CoreData

extension ConversationEntity {
    static func fetchRequest(forId id: String) -> NSFetchRequest<ConversationEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forIds ids: Set<String>) -> NSFetchRequest<ConversationEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return request
    }
    
    static func fetchRequest(notIn ids: Set<String>) -> NSFetchRequest<ConversationEntity> {
        let request = Self.fetchRequest()
        request.predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        return request
    }
    
    func batchSaveMessages(messages: [ConversationMessageEssentials], context: NSManagedObjectContext) throws {
        let existingItems = try context.fetch(ConversationMessageEntity.fetchRequest(forIds: Set(messages.compactMap { $0.id })))
        let existingItemsDict: [String: ConversationMessageEntity] = Dictionary(uniqueKeysWithValues: existingItems.compactMap({ $0.id != nil ? ($0.id!, $0) : nil }))
        
        for item in messages {
            let entity: ConversationMessageEntity
            
            if let existingEntity = existingItemsDict[item.id] {
                entity = existingEntity
            } else {
                let newEntity = ConversationMessageEntity(context: context)
                newEntity.id = item.id
                newEntity.index = Int32(item.index)
                newEntity.sender = item.sender.createOrModifyUserEntity(context: context)
                newEntity.conversation = self
                newEntity.createdAt = item.createdAt
                entity = newEntity
            }
            
            entity.content = item.content
            entity.updatedAt = item.updatedAt
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    static func batchSaveConversations(conversations: [Conversation], context: NSManagedObjectContext) throws {
        let conversationIds = Set(conversations.compactMap { $0.id })
        let existingItems = try context.fetch(ConversationEntity.fetchRequest(forIds: conversationIds))
        let existingItemsDict: [String: ConversationEntity] = Dictionary(uniqueKeysWithValues: existingItems.compactMap({ $0.id != nil ? ($0.id!, $0) : nil }))
        
        // Participants
        let participantsFetch = try context.fetch(ConversationParticipantEntity.fetchRequest(conversationIds: conversationIds))
        let participantsDict: [String: [ConversationParticipantEntity]] = Dictionary(grouping: participantsFetch.compactMap({ $0.conversation?.id != nil ? $0 : nil })) { $0.conversation!.id! }
        
        // Users
        let participants = conversations.flatMap { $0.participants }.map { $0.user.id }
        let usersFetch = try context.fetch(UserEntity.fetchRequest(forIds: Set(participants)))
        let usersDict: [String: UserEntity] = Dictionary(uniqueKeysWithValues: usersFetch.compactMap({ $0.id != nil ? ($0.id!, $0) : nil }))
        
        for item in conversations {
            let participants = item.participants.map { p in
                let pEntity: ConversationParticipantEntity
                
                if let participantArray = participantsDict[item.id], let found = participantArray.first(where: { $0.user?.id == p.user.id }) {
                    pEntity = found
                } else {
                    pEntity = ConversationParticipantEntity(context: context)
                }
                
                pEntity.readIndex = Int32(p.read?.index ?? -1)
                pEntity.readDate = p.read?.date
                
                pEntity.user = usersDict[p.user.id] ?? p.user.createOrModifyUserEntity(context: context)
                
                return pEntity
            }
            
            let entity: ConversationEntity
            
            if let existingEntity = existingItemsDict[item.id] {
                entity = existingEntity
            } else {
                let newEntity = ConversationEntity(context: context)
                newEntity.id = item.id
                newEntity.createdAt = item.createdAt
                
                entity = newEntity
            }
            
            participants.forEach { $0.conversation = entity }
            
            entity.title = item.title
            entity.lastActivity = item.lastActivity
            entity.lastMessageIndex = Int32(item.lastMessageIndex)
            entity.updatedAt = item.updatedAt
            entity.participants = NSSet(array: participants)
            
            if let lastMessage = item.lastMessage {
                try lastMessage.createOrUpdateConversationMessageEntity(context: context, conversation: entity)
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
}
