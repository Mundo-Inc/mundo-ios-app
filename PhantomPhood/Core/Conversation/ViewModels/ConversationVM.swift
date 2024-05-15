//
//  ConversationVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import Foundation
import TwilioConversationsClient
import Combine

class ConversationVM: LoadingSections, ObservableObject {
    @Published var messages = [PersistentMessageDataItem]()
    
    @Published var messageText = ""
    @Published var usersDict: [String:UserEssentials] = [:]
    @Published var transactionsDict: [String:Transaction] = [:]
    @Published var loadingSections = Set<LoadingSection>()
    
    enum LoadingSection: Hashable {
        case sendingMessage
        case loadingTransaction(String)
    }
    
    private let userProfileDM = UserProfileDM()
    private let transactionsDM = TransactionsDM()
    private var coreDataDelegate = ConversationsManager.shared.coreDataManager
    private var conversationManager = ConversationsManager.shared
    private var cancellables: Set<AnyCancellable> = []
    
    let conversationSid: String
    
    @Published var friendlyName: String? = nil
    @Published var participants: [TCHParticipant] = []
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
        
        DispatchQueue.main.async {
            self.friendlyName = conversation.friendlyName
        }
        
        if let currentUser = Authentication.shared.currentUser {
            let participants = conversation.participants().filter({ p in
                if let identity = p.identity {
                    return identity != currentUser.id
                }
                return false
            })
            
            DispatchQueue.main.async {
                self.participants = participants
            }
            
            for p in participants {
                if let userId = p.identity {
                    do {
                        if let user = try await userProfileDM.getUserEssentialsAndUpdate(id: userId, returnIfFound: true, coreDataCompletion: { user in
                            DispatchQueue.main.async {
                                self.usersDict[user.id] = user
                            }
                        }) {
                            DispatchQueue.main.async {
                                self.usersDict[user.id] = user
                            }
                        }
                    } catch {
                        presentErrorToast(error, debug: "Error fetching user info")
                    }
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
                receiveCompletion: { _ in },
                receiveValue: { [weak self] items in
                    self?.messages = items
                }
            )
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
                
                try await coreDataDelegate.saveContext()
            }
        } catch {
            presentErrorToast(error, debug: "Error retriving last messages")
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
                
                try await coreDataDelegate.saveContext()
            }
        } catch {
            presentErrorToast(error, debug: "Error retriving messages")
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
                presentErrorToast(result.error!, debug: "Error updating message")
            } else {
                ToastVM.shared.toast(.init(type: .success, title: "Success", message: "Message attributes updated successfully"))
            }
        } catch {
            presentErrorToast(error, debug: "Error updating message")
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
            presentErrorToast(error, debug: "Error deleting message")
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
            presentErrorToast(error, debug: "Error sending message")
        }
    }
    
    func markAllMessagesAsRead() async {
        do {
            let conversation = try await getConversation()
            
            // (result, updatedUnreadMessageCount)
            let (result, _) = await conversation.setAllMessagesRead()
            
            if !result.isSuccessful, let error = result.error {
                presentErrorToast(error, debug: "Error setting messages as read for conversation \(conversationSid)")
            }
        } catch {
            presentErrorToast(error, silent: true)
        }
    }
}


extension ConversationVM {
    func fetchTransaction(withId id: String) async {
        guard transactionsDict[id] == nil, !loadingSections.contains(.loadingTransaction(id)) else { return }
        
        setLoadingState(.loadingTransaction(id), to: true)
        do {
            let data = try await transactionsDM.getTransaction(withId: id)
            await MainActor.run {
                transactionsDict[id] = data
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.loadingTransaction(id), to: false)
    }
}
