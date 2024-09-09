//
//  ConversationVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/5/24.
//

import Foundation
import Combine
import SwiftUI

final class ConversationVM: ObservableObject {
    @Published var content: String = ""
    
    @Published private(set) var recepient: Recepient? = nil
    @Published private(set) var exists: Bool? = nil
    @Published private(set) var conversation: Conversation?
    @Published private(set) var messages: [ConversationMessageEssentials] = []
    private var lastReadIndex: Int = -1
    
    private var cancellables = Set<AnyCancellable>()
    
    enum Recepient {
        case direct(Conversation.Participant)
        case group([Conversation.Participant])
    }
    
    init(id: String) {
        Task {
            do {
                let data = try await Conversation.fetch(id: id, useCoreData: true)
                
                DispatchQueue.main.async {
                    let currentUserId = Authentication.shared.currentUser?.id
                    
                    self.exists = true
                    self.conversation = data.struct
                    self.recepient = if data.struct.participants.count == 2, let participant = data.struct.participants.first(where: { $0.user.id != currentUserId }) {
                        .direct(participant)
                    } else {
                        .group(data.struct.participants.filter({ $0.user.id != currentUserId }))
                    }
                }
                
                if let user = data.struct.participants.first(where: { $0.user.id == Authentication.shared.currentUser?.id }), let read = user.read {
                    lastReadIndex = read.index
                }
                
                let messages = try await ConversationMessageEssentials.fetch(covnersationId: id)
                
                let context = DataStack.shared.viewContext
                try await context.perform {
                    try data.entity.batchSaveMessages(messages: messages, context: context)
                }
            } catch {
                presentErrorToast(error)
            }
        }
        
        setCDPublisher(conversationId: id)
    }
    
    init(user: IdOrData<UserEssentials>) {
        let userId: String
        
        switch user {
        case .id(let id):
            userId = id
        case .data(let userEssntials):
            DispatchQueue.main.async {
                self.recepient = .direct(.init(user: userEssntials, read: nil))
            }
            userId = userEssntials.id
        }
        
        Task {
            do {
                let data = try await Conversation.fetch(withUser: userId)
                
                DispatchQueue.main.async {
                    let currentUserId = Authentication.shared.currentUser?.id
                    
                    self.exists = true
                    self.conversation = data.struct
                    self.recepient = if data.struct.participants.count == 2, let participant = data.struct.participants.first(where: { $0.user.id != currentUserId }) {
                        .direct(participant)
                    } else {
                        .group(data.struct.participants.filter({ $0.user.id != currentUserId }))
                    }
                }
                
                if let user = data.struct.participants.first(where: { $0.user.id == Authentication.shared.currentUser?.id }), let read = user.read {
                    lastReadIndex = read.index
                }
                
                let messages = try await ConversationMessageEssentials.fetch(covnersationId: data.struct.id)
                
                let context = DataStack.shared.viewContext
                try await context.perform {
                    try data.entity.batchSaveMessages(messages: messages, context: context)
                }
                
                setCDPublisher(conversationId: data.struct.id)
            } catch {
                DispatchQueue.main.async {
                    self.exists = false
                }
                
                let userProfileDM = UserProfileDM()
                if let user = try await userProfileDM.getUserEssentialsAndUpdate(id: userId, returnIfFound: true, coreDataCompletion: { user in
                    DispatchQueue.main.async {
                        self.recepient = .direct(.init(user: user, read: nil))
                    }
                }) {
                    DispatchQueue.main.async {
                        self.recepient = .direct(.init(user: user, read: nil))
                    }
                }
            }
        }
    }
    
    func setReadIndex(index: Int) {
        guard let conversation, index > lastReadIndex else { return }
        
        ConversationManager.shared.setReadIndex(conversation: conversation.id, index: index)
    }
    
    func handleSend() {
        guard let exists else { return }
        
        if let conversation, exists {
            ConversationManager.shared.sendMessage(conversation: conversation.id, content: content)
        } else if let recepient {
            if case .direct(let participant) = recepient {
                Task {
                    let data = try await Conversation.create(recipient: participant.user.id, content: content)
                    
                    DispatchQueue.main.async {
                        let currentUserId = Authentication.shared.currentUser?.id
                        
                        self.exists = true
                        self.conversation = data.struct
                        self.recepient = if data.struct.participants.count == 2, let participant = data.struct.participants.first(where: { $0.user.id != currentUserId }) {
                            .direct(participant)
                        } else {
                            .group(data.struct.participants.filter({ $0.user.id != currentUserId }))
                        }
                    }
                    
                    setCDPublisher(conversationId: data.struct.id)
                }
            }
        } else {
            print("Hmm...")
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.content = ""
            }
        }
    }
    
    private func setCDPublisher(conversationId: String) {
        let request = ConversationMessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id == %@", conversationId)
        
        request.sortDescriptors = [
            .init(keyPath: \ConversationMessageEntity.createdAt, ascending: true)
        ]
        
        CDPublisher(request: request, context: DataStack.shared.viewContext)
            .map({ $0.compactMap { entity in
                do {
                    return try ConversationMessageEssentials(entity: entity)
                } catch {
                    return nil
                }
            } })
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { self.messages = $0 }
            .store(in: &cancellables)
    }
}
