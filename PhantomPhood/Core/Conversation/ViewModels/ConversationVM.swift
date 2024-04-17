//
//  ConversationVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import Foundation
import TwilioConversationsClient
import Combine

class ConversationVM: ObservableObject {
    @Published var messages = [PersistentMessageDataItem]()
    
    @Published var messageText = ""
    @Published var user: UserEssentials? = nil
    @Published var loadingSections = Set<LoadingSection>()
    
    enum LoadingSection: Hashable {
        case sendingMessage
    }
    
    private let userProfileDM = UserProfileDM()
    private var coreDataDelegate = ConversationsManager.shared.coreDataManager
    private var conversationManager = ConversationsManager.shared
    private var cancellables: Set<AnyCancellable> = []
    
    let conversationSid: String
    private var conversation: TCHConversation? = nil
    
    init(sid: String) {
        self.conversationSid = sid
        
        subscribeMessages()
        
        $messageText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { value in
                if !value.isEmpty {
                    Task {
                        await self.typing()
                    }
                }
            }
            .store(in: &cancellables)
        
        Task {
            await getTargetUserInfo()
        }
    }
    
    private func getTargetUserInfo() async {
        guard let conversation = try? await getConversation() else { return }
        
        if let currentUser = Authentication.shared.currentUser {
            let participants = conversation.participants().filter({ p in
                if let identity = p.identity {
                    return identity != currentUser.id
                }
                return false
            })
            
            if let first = participants.first, let userId = first.identity {
                do {
                    if let user = try await userProfileDM.getUserEssentialsAndUpdate(id: userId, returnIfFound: true, coreDataCompletion: { user in
                        DispatchQueue.main.async {
                            self.user = user
                        }
                    }) {
                        self.user = user
                    }
                } catch {
                    print("DEBUG: Error fetching user info", error)
                }
            }
        }
    }
    
    private func getConversation() async throws -> TCHConversation {
        if let conversation {
            return conversation
        } else {
            let conversation = try await conversationManager.retrieveConversation(conversationSid)
            self.conversation = conversation
            return conversation
        }
    }
    
    func subscribeMessages() {
        #if DEBUG
        print("Setting up Core Data update subscription for Messages in conversation \(conversationSid)")
        #endif
        
        let request = PersistentMessageDataItem.fetchRequest()
        request.predicate = NSPredicate(format: "conversationSid = %@", conversationSid)
        request.sortDescriptors = [NSSortDescriptor(key: "messageIndex", ascending: true)]
        
        ObservableResultPublisher(with: request, context: coreDataDelegate.viewContext)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {
                    print("Completion from fetch messages - \($0)")
                },
                receiveValue: { [weak self] items in
                    DispatchQueue.main.async {
                        self?.messages = items
                    }
                })
            .store(in: &cancellables)
    }
    
    func loadLastMessages() async {
        do {
            let conversation = try await getConversation()

            let (_, unreadCount) = await conversation.unreadMessagesCount()
            
            let withCount: UInt
            if let unreadCount, let unread = UInt(exactly: unreadCount) {
                withCount = max(unread, 40)
            } else {
                withCount = 40
            }
            
            let (_, messages) = await conversation.lastMessages(withCount: withCount)
            
            if let messages {
                messages.forEach({
                    PersistentMessageDataItem.from(
                        message: $0,
                        inConversation: conversation,
                        withDirection: $0.author == self.conversationManager.myUser?.identity ? .outgoing : .incoming,
                        inContext: self.coreDataDelegate.viewContext
                    )
                })
                
                try coreDataDelegate.saveContext()
            }
        } catch {
            print("Error retriving last messages", error)
        }
    }
    
    func loadMessages(before messageIndex: Int64, max: UInt) async {
        do {
            let conversation = try await getConversation()
            
            // getMessagesBefore fetches at most count messages including and prior to the specified index. Therefore we need
            // to ask for 1 more than max, to get the exact max that we want.
            let (_, messages) = await conversation.messages(before: UInt(messageIndex), withCount: max + 1)
            
            if let messages {
                messages.forEach({
                    PersistentMessageDataItem.from(
                        message: $0,
                        inConversation: conversation,
                        withDirection: $0.author == self.conversationManager.myUser?.identity ? .outgoing : .incoming,
                        inContext: self.coreDataDelegate.viewContext
                    )
                })
                
                try coreDataDelegate.saveContext()
            }
        } catch {
            print("Error retriving messages", error)
        }
    }
    
    func updateMessage(attributes: [String: Any]?, for messageIndex: Int64?) async {
        guard let attributes, let messageIndex else {
            return
        }
        
        do {
            let conversation = try await getConversation()
            
            let (_, messageToUpdate) = await conversation.message(withIndex: NSNumber(integerLiteral: Int(messageIndex)))
            
            guard let messageToUpdate, let jsonAttributes = TCHJsonAttributes(dictionary: attributes) else {
                return
            }
            
            let result = await messageToUpdate.setAttributes(jsonAttributes)
            
            if result.error != nil {
                print("Updating message attributes returned an error: \(String(describing: result.error)) - error code: \(result.resultCode)")
            } else {
                print("Message attributes updated successfully!")
            }
        } catch {
            print("Error retriving last messages", error)
        }
    }
    
    private func retrieveMessageIn(_ conversation: TCHConversation, messageIndex: NSNumber) async throws -> TCHMessage {
        let (result, message) = await conversation.message(withIndex: messageIndex)
        
        guard result.isSuccessful, let message else {
            throw DataFetchError.requiredDataCallsFailed
        }
        
        return message
    }
    
    func copyMessage() {
        conversationManager.conversationEventPublisher.send(.messageCopied)
    }
    
    func typing() async {
        guard let conversation = try? await getConversation() else { return }
        
        conversation.typing()
    }
    
    func deleteMessage(_ message: PersistentMessageDataItem) async {
        let messageIndex = NSNumber(value: message.messageIndex)
        
        do {
            let conversation = try await getConversation()
            
            let message = try await retrieveMessageIn(conversation, messageIndex: messageIndex)
            
            let result = await conversation.remove(message)
            
            if result.isSuccessful {
                self.conversationManager.conversationEventPublisher.send(.messageDeleted)
            }
        } catch {
            print("Error retriving last messages", error)
        }
    }
    
    func sendMessage(andMedia url: NSURL? = nil, withFileName filename: String? = nil, text: String? = nil, completion: @escaping (TCHError?) -> ()) async {
        DispatchQueue.main.async {
            self.loadingSections.insert(.sendingMessage)
        }
        
        let textToSend = text ?? self.messageText
        
        do {
            let conversation = try await getConversation()
            
            if let url {
                conversation.prepareMessage()
                    .addMedia(inputStream: InputStream(url: url as URL)!, contentType: "image/jpeg", filename: filename, listener: .init(onStarted: {
                        // Called when upload of media begins.
                        print("[MediaMessage] Media upload started")
                    }, onProgress: { bytesSent in
                        print("Current progress \(bytesSent)")
                        _ = MediaMessageProperties(mediaURL: nil,
                                                   messageSize: -1,
                                                   uploadedSize: Int(bytesSent))
                    }, onCompleted: { mediaSid in
                        print("[MediaMessage] Upload completed for sid \(mediaSid)")
                        
                        if text == nil {
                            DispatchQueue.main.async {
                                self.messageText = ""
                            }
                        }
                        
                        completion(nil)
                    }, onFailed: { error in
                        print("Media upload failed with error \(error)")
                    }))
                    .buildAndSend { result, message in
                        DispatchQueue.main.async {
                            self.loadingSections.remove(.sendingMessage)
                        }
                        
                        if let error = result.error {
                            print("Error encountered while sending message: \(error)")
                            return completion(result.error)
                        }
                        
                        if text == nil {
                            DispatchQueue.main.async {
                                self.messageText = ""
                            }
                        }
                        
                        completion(nil)
                    }
            } else {
                guard textToSend.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
                    return
                }
                
                conversation.prepareMessage()
                    .setBody(textToSend)
                    .buildAndSend { result, message in
                        DispatchQueue.main.async {
                            self.loadingSections.remove(.sendingMessage)
                        }
                        
                        if let error = result.error {
                            print("Error encountered while sending message: \(error)")
                            return completion(result.error)
                        }
                        
                        if text == nil {
                            DispatchQueue.main.async {
                                self.messageText = ""
                            }
                        }
                        
                        completion(nil)
                    }
            }
        } catch {
            DispatchQueue.main.async {
                self.loadingSections.remove(.sendingMessage)
            }
            print("Error sending message", error)
        }
    }
    
    func markAllMessagesAsRead() async {
        do {
            let conversation = try await getConversation()
            
            // (result, updatedUnreadMessageCount)
            let (result, _) = await conversation.setAllMessagesRead()
            
            #if DEBUG
            if result.isSuccessful {
                print("All messages set as read for conversation \(conversationSid)")
            } else {
                print("Error - not able to set all messages as read for conversation \(conversationSid)")
            }
            #endif
        } catch {
            print("Error markAllMessagesAsRead", error)
        }
    }
}
