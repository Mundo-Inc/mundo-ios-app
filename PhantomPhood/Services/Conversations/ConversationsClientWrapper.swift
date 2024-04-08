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
            print("DEBUG: Error getting conversations token | \(error)")
            throw error
        }
    }
    
    func updateToken() async {
        guard let conversationsClient else {
            print("DEBUG: Conversations Client Not Found")
            return
        }
        
        do {
            let token = try await conversationsDM.getToken()
            await conversationsClient.updateToken(token)
        } catch {
            print("DEBUG: Error getting conversations token | \(error)")
        }
    }
        
    func shutdown() {
        conversationsClient?.shutdown()
        conversationsClient = nil
    }
        
    // MARK: - Credentials Events
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        Task {
            await self.updateToken()
        }
    }
    
    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        Task {
            await self.updateToken()
        }
    }
}
