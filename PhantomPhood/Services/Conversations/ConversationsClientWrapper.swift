//
//  ConversationsClientWrapper.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation
import TwilioConversationsClient

final class ConversationsClientWrapper: NSObject, ObservableObject {
    private let conversationsDM = ConversationsDM()
    
    private(set) var conversationsClient: TwilioConversationsClient?
    
    func create() async throws {
        do {
            let token = try await conversationsDM.getToken()
            
            // Create conversations client with token
            TwilioConversationsClient.setLogLevel(.silent)
            
            let properties = TwilioConversationsClientProperties()
            properties.dispatchQueue = DispatchQueue(label: "TwilioConversationsDispatchQueue")
            let (result, client) = await TwilioConversationsClient.conversationsClient(withToken: token, properties: properties, delegate: ConversationsManager.shared)
            if result.isSuccessful, let client {
                DispatchQueue.main.async {
                    self.conversationsClient = client
                    
                    // Setting myUser value
                    ConversationsManager.shared.myUser = client.user
                    
                    // Populating conversations
                    ConversationsManager.shared.subscribeConversations(onRefresh: false)
                }
            } else {
                throw result.error!
            }
        } catch {
            presentErrorToast(error, debug: "Error getting conversations token", silent: true)
            throw error
        }
    }
    
    func updateToken() async throws {
        if conversationsClient == nil {
            try await self.create()
        }
        
        guard let conversationsClient else {
            throw URLError(.unknown)
        }
        
        let token = try await conversationsDM.getToken()
        await conversationsClient.updateToken(token)
    }
        
    func shutdown() {
        conversationsClient?.shutdown()
        conversationsClient = nil
    }
        
    // MARK: - Credentials Events
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        Task {
            try? await self.updateToken()
        }
    }
    
    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        Task {
            try? await self.updateToken()
        }
    }
}
