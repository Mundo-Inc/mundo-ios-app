//
//  ConversationManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/28/24.
//

import Foundation
import Combine

final class ConversationManager: ObservableObject, SocketListener {
    static let shared = ConversationManager()
    
    private let conversationDM = ConversationDM()
    
    private let socketService = SocketService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var conversations: [Conversation] = []
    
    
    private init() {
        addSocketListener()
        
        setCDPublisher()
    }
    
    deinit {
        removeSocketListener()
    }
    
    func addSocketListener() {
        socketService.addListener(for: .newMessage, id: #file.description) { data, ack in
            guard let result: ConversationMessage = try? APIManager.getData(data) else { return }
            
            let context = DataStack.shared.viewContext
            context.perform {
                result.createOrUpdateConversationMessageEntity(context: context, conversation: nil, save: true)
            }
            
            if result.sender.id != Authentication.shared.currentUser?.id {
                ToastVM.shared.toast(.init(type: .info, title: result.sender.name, message: result.content ?? "New message"))
            }
        }
        
        socketService.addListener(for: .updateReadIndex, id: #file.description) { data, ack in
            guard let result: Conversation = try? APIManager.getData(data) else { return }
            
            let context = DataStack.shared.viewContext
            context.perform {
                result.createOrUpdateConversationEntity(context: context, save: true)
            }
        }
    }
    
    func removeSocketListener() {
        socketService.removeListener(for: .newMessage, id: #file.description)
        socketService.removeListener(for: .updateReadIndex, id: #file.description)
    }
    
    func sendMessage(conversation: String, content: String) {
        socketService.request(for: .newMessage(conversation: conversation, content: content))
    }
    
    func setReadIndex(conversation: String, index: Int) {
        socketService.request(for: .updateReadIndex(conversation: conversation, index: index))
    }
    
    func getConversations() async {
        do {
            let data = try await conversationDM.getConversations()
            
            let context = DataStack.shared.viewContext
            
            guard !data.data.isEmpty else {
                try? await context.perform {
                    let request = ConversationEntity.fetchRequest()
                    let conversations = try context.fetch(request)
                    conversations.forEach { context.delete($0) }
                    try context.save()
                }
                return
            }
            
            let request = ConversationEntity.fetchRequest(notIn: Set(data.data.map({ $0.id })))
            
            try? await context.perform {
                let conversations = try context.fetch(request)
                conversations.forEach { context.delete($0) }
                
                try ConversationEntity.batchSaveConversations(conversations: data.data, context: context)
                
                try context.save()
            }

        } catch {
            presentErrorToast(error)
        }
    }
    
    private func setCDPublisher() {
        let request = ConversationEntity.fetchRequest()
        
        request.sortDescriptors = [
            .init(keyPath: \ConversationEntity.lastActivity, ascending: false)
        ]
        
        CDPublisher(request: request, context: DataStack.shared.viewContext)
            .map({ $0.compactMap { entity in
                try? Conversation(entity: entity)
            } })
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { self.conversations = $0 }
            .store(in: &cancellables)
    }
}
