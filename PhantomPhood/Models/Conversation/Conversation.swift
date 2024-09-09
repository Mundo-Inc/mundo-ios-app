//
//  Conversation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/28/24.
//

import Foundation
import CoreData

struct Conversation: Identifiable, Decodable {
    static let dm = ConversationDM()
    
    let id: String
    let participants: [Participant]
    let title: String?
    let lastActivity: Date
    let lastMessageIndex: Int
    let lastMessage: ConversationMessageEssentials?
    
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case participants, title, lastActivity, lastMessageIndex, lastMessage, createdAt, updatedAt
    }
    
    struct Participant: Decodable {
        let user: UserEssentials
        let read: Read?
        
        struct Read: Decodable {
            let index: Int
            let date: Date
        }
    }
    
    @discardableResult
    func createOrUpdateConversationEntity(context: NSManagedObjectContext, save: Bool = false) -> ConversationEntity {
        let entity = if let result = try? context.fetch(ConversationEntity.fetchRequest(forId: self.id)), let first = result.first {
            first
        } else {
            ConversationEntity(context: context)
        }
        
        entity.id = self.id
        entity.title = self.title
        entity.lastActivity = self.lastActivity
        entity.lastMessageIndex = Int32(self.lastMessageIndex)
        entity.createdAt = self.createdAt
        entity.updatedAt = self.updatedAt
        
        let participants = self.participants.map { p in
            let pRequest = ConversationParticipantEntity.fetchRequest()
            pRequest.predicate = NSPredicate(format: "user.id == %@ AND conversation.id == %@", p.user.id, self.id)
            
            let pEntity = if let result = try? context.fetch(pRequest), let first = result.first {
                first
            } else {
                ConversationParticipantEntity(context: context)
            }
            
            pEntity.readIndex = Int32(p.read?.index ?? -1)
            pEntity.readDate = p.read?.date
            
            pEntity.user = p.user.createOrModifyUserEntity(context: context)
            pEntity.conversation = entity
            
            return pEntity
        }
        
        entity.participants = NSSet(array: participants)
        
        if let lastMessage {
            do {
                try lastMessage.createOrUpdateConversationMessageEntity(context: context, conversation: entity, save: true)
            } catch {
                presentErrorToast(error, silent: true)
            }
        }
        
        if save {
            do {
                try context.save()
            } catch {
                presentErrorToast(error, debug: "Error saving context", silent: true)
            }
        }
        
        return entity
    }
    
    @discardableResult
    func createConversationEntity(context: NSManagedObjectContext, save: Bool = false) -> ConversationEntity {
        let entity = ConversationEntity(context: context)
        
        entity.id = self.id
        entity.title = self.title
        entity.lastActivity = self.lastActivity
        entity.lastMessageIndex = Int32(self.lastMessageIndex)
        entity.createdAt = self.createdAt
        entity.updatedAt = self.updatedAt
        
        let participants = self.participants.map { p in
            let pRequest = ConversationParticipantEntity.fetchRequest()
            pRequest.predicate = NSPredicate(format: "user.id == %@ AND conversation.id == %@", p.user.id, self.id)
            
            let pEntity = if let result = try? context.fetch(pRequest), let first = result.first {
                first
            } else {
                ConversationParticipantEntity(context: context)
            }
            
            pEntity.readIndex = Int32(p.read?.index ?? -1)
            pEntity.readDate = p.read?.date
            
            pEntity.user = p.user.createOrModifyUserEntity(context: context)
            pEntity.conversation = entity
            
            return pEntity
        }
        
        entity.participants = NSSet(array: participants)
        
        if let lastMessage {
            do {
                try lastMessage.createOrUpdateConversationMessageEntity(context: context, conversation: entity, save: true)
            } catch {
                presentErrorToast(error, silent: true)
            }
        }
        
        if save {
            do {
                try context.save()
            } catch {
                presentErrorToast(error, debug: "Error saving context", silent: true)
            }
        }
        
        return entity
    }
    
    func getLastMessage() -> ConversationMessageEssentials? {
        let fetchRequest = ConversationMessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ConversationMessageEntity.createdAt, ascending: false)
        ]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "conversation.id == %@", self.id)
        
        let context = DataStack.shared.viewContext
        return context.performAndWait {
            let result = try? context.fetch(fetchRequest)
            
            if let first = result?.first, let message = try? ConversationMessageEssentials(entity: first) {
                return message
            }
            
            return nil
        }
    }
    
    func getUnread(for userId: String) -> Int? {
        if let found = participants.first(where: { $0.user.id == userId }) {
            return lastMessageIndex - (found.read?.index ?? -1)
        }
        
        return nil
    }
}

extension Conversation {
    init(entity: ConversationEntity) throws {
        guard let id = entity.id, let participantEntites = entity.participants?.allObjects as? [ConversationParticipantEntity], let lastActivity = entity.lastActivity, let createdAt = entity.createdAt, let updatedAt = entity.updatedAt else {
            throw EntityError.missingStructRequiredData
        }
        
        self.id = id
        self.participants = participantEntites.compactMap({ e in
            if let userEntity = e.user, let user = try? UserEssentials(entity: userEntity) {
                if let date = e.readDate {
                    return .init(user: user, read: .init(index: Int(e.readIndex), date: date))
                }
                return .init(user: user, read: nil)
            } else {
                return nil
            }
        })
        self.title = entity.id
        self.lastActivity = lastActivity
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessage = nil
        self.lastMessageIndex = Int(entity.lastMessageIndex)
    }
}

extension Conversation {
    static func fromCoreData(id: String, context: NSManagedObjectContext) async -> (struct: Self, entity: ConversationEntity)? {
        let fetchRequest = ConversationEntity.fetchRequest(forId: id)
        
        return await context.perform {
            let data = try? context.fetch(fetchRequest)
            
            if let conversationEntity = data?.first, let conversation = try? Conversation(entity: conversationEntity) {
                return (conversation, conversationEntity)
            } else {
                return nil
            }
        }
    }
}

// MARK: - Data Manager

extension Conversation {
    func getMessages(lastMessage: String? = nil, limit: Int = 100) async throws -> [ConversationMessageEssentials] {
        let data = try await Self.dm.getMessages(covnersation: self.id, lastMessage: lastMessage, limit: limit)
        return data.data
    }
    
    func delete() async throws {
        try await Self.dm.delete(covnersation: self.id)
    }
    
    /// Gets Conversation struct and Entity
    /// - Creates the entity if not exists
    static func fetch(id: String, useCoreData: Bool = false) async throws -> (struct: Self, entity: ConversationEntity) {
        let context = DataStack.shared.viewContext
        
        if useCoreData {
            if let conversation = await Self.fromCoreData(id: id, context: context) {
                return conversation
            }
        }
        
        let data = try await dm.getCovnersation(id: id)
        
        let entity = context.performAndWait {
            data.data.createOrUpdateConversationEntity(context: context)
        }
        
        return (data.data, entity)
    }
    
    static func fetch(withUser userId: String) async throws -> (struct: Self, entity: ConversationEntity) {
        let data = try await Self.dm.getCovnersationWith(userId: userId)
        
        let context = DataStack.shared.viewContext
        let entity = context.performAndWait {
            data.data.createOrUpdateConversationEntity(context: context)
        }
        
        return (data.data, entity)
    }
    
    static func create(recipient: String, content: String) async throws -> (struct: Self, entity: ConversationEntity) {
        let data = try await Self.dm.create(recipient: recipient, content: content)
        
        let context = DataStack.shared.viewContext
        let entity = context.performAndWait {
            data.data.createOrUpdateConversationEntity(context: context)
        }
        
        return (data.data, entity)
    }
}
