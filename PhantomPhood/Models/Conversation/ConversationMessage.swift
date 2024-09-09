//
//  ConversationMessage.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/28/24.
//

import Foundation
import CoreData

struct ConversationMessage: Identifiable, Decodable {
    let id: String
    let content: String?
    let conversation: Conversation
    let sender: UserEssentials
    let index: Int
    
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversation, sender, content, index, createdAt, updatedAt
    }
    
    @discardableResult
    func createOrUpdateConversationMessageEntity(context: NSManagedObjectContext, conversation: ConversationEntity?, save: Bool = false) -> ConversationMessageEntity {
        let entity = if let result = try? context.fetch(ConversationMessageEntity.fetchRequest(forId: self.id)), let first = result.first {
            first
        } else {
            ConversationMessageEntity(context: context)
        }
        
        let conversationEntity: ConversationEntity
        if let conversation {
            conversationEntity = conversation
        } else {
            conversationEntity = self.getConversationEntity(context: context)
        }
        
        entity.id = self.id
        entity.content = self.content
        entity.index = Int32(self.index)
        entity.conversation = conversationEntity
        entity.sender = sender.createOrModifyUserEntity(context: context)
        entity.createdAt = self.createdAt
        entity.updatedAt = self.updatedAt
        
        if save {
            do {
                try context.save()
            } catch {
                presentErrorToast(error, debug: "Error saving context", silent: true)
            }
        }
        
        return entity
    }
    
    func getConversationEntity(context: NSManagedObjectContext) -> ConversationEntity {
        let fetchResult = try? context.fetch(ConversationEntity.fetchRequest(forId: self.conversation.id))
        let entity = fetchResult?.first ?? self.conversation.createConversationEntity(context: context)
        return entity
    }
}
