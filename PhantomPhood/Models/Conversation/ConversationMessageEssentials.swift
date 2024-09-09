//
//  ConversationMessageEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/6/24.
//

import Foundation
import CoreData

struct ConversationMessageEssentials: Identifiable, Decodable {
    let id: String
    let conversation: String
    let content: String?
    let sender: UserEssentials
    let index: Int
    
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversation, sender, content, index, createdAt, updatedAt
    }
    
    @discardableResult
    func createOrUpdateConversationMessageEntity(context: NSManagedObjectContext, conversation: ConversationEntity?, save: Bool = false) throws -> ConversationMessageEntity {
        if let result = try? context.fetch(ConversationMessageEntity.fetchRequest(forId: self.id)), let entity = result.first {
            entity.id = self.id
            entity.content = self.content
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
        } else {
            let covnersationEntity: ConversationEntity
            
            if let conversation {
                covnersationEntity = conversation
            } else if let conversationFetch = try? context.fetch(ConversationEntity.fetchRequest(forId: self.conversation)), let first = conversationFetch.first {
                covnersationEntity = first
            } else {
                throw EntityError.notFound
            }
            
            let entity = ConversationMessageEntity(context: context)
            entity.id = self.id
            entity.content = self.content
            entity.index = Int32(self.index)
            entity.conversation = covnersationEntity
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
    }
}

// MARK: - Init

extension ConversationMessageEssentials {
    init(entity: ConversationMessageEntity) throws {
        guard let id = entity.id,
              let conversation = entity.conversation?.id,
              let content = entity.content,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt,
              let sender = entity.sender,
              let senderUser = try? UserEssentials(entity: sender) else {
            
            throw EntityError.missingStructRequiredData
        }
        
        self.id = id
        self.conversation = conversation
        self.content = content
        self.index = Int(entity.index)
        self.sender = senderUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Data Manager

extension ConversationMessageEssentials {
    private static let dm = ConversationDM()
    
    static func fetch(covnersationId: String, lastMessage: String? = nil, limit: Int = 100) async throws -> [Self] {
        let data = try await dm.getMessages(covnersation: covnersationId, lastMessage: lastMessage, limit: limit)
        
        return data.data
    }
}
