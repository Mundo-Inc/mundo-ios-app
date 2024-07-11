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
    
    private var initSetting = false
    
    func create() async throws {
        do {
            if !initSetting {
                TwilioConversationsClient.setLogLevel(.silent)
            }
            
            let token = try await conversationsDM.getToken()
            
            // Create conversations client with token
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
            } else if let error = result.error {
                throw error
            } else {
                print("Unable to create Twilio client")
            }
        } catch {
            presentErrorToast(error, debug: "Error getting conversations token", silent: true)
            throw error
        }
    }
    
    func updateToken() async throws {
        guard let conversationsClient else {
            throw URLError(.unknown)
        }
        
        let token = try await conversationsDM.getToken()
        await conversationsClient.updateToken(token)
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
