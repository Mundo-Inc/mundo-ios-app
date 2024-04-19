//
//  ConversationsManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/3/24.
//

import Foundation
import Combine
import TwilioConversationsClient

final class ConversationsManager: NSObject, ObservableObject {
    static let shared = ConversationsManager()
    
    @Published var conversations = [PersistentConversationDataItem]()
    @Published var isConversationsLoading = false
    @Published var isConversationsRefreshing = false
    @Published var myUser: TCHUser? = nil
    
    @Published var conversationsError: TCHError? = nil
    
    private var clientState: TCHClientConnectionState = .unknown
    private(set) var client: ConversationsClientWrapper = ConversationsClientWrapper()
    
    var coreDataManager = ConversationsCoreDataManager()
    
    public var typingPublisher = PassthroughSubject<TypingActivity, Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Events
    
    var conversationEventPublisher = PassthroughSubject<ConversationEvent, Never>()
    
    // MARK: Methods
    
    func subscribeConversations(onRefresh: Bool) {
        if (onRefresh) {
            isConversationsRefreshing = true
        } else {
            isConversationsLoading = true
        }
        print("Setting up Core Data update subscription for Conversations")
        
        let request = PersistentConversationDataItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastMessageDate", ascending: false),
            NSSortDescriptor(key: "friendlyName", ascending: true)]
        
        ObservableResultPublisher(with: request, context: coreDataManager.viewContext)
            .sink(
                receiveCompletion: {
                    NSLog("Completion from fetch conversations - \($0)")
                },
                receiveValue: { [weak self] items in
                    let sortedItems = items.sorted(by: self!.sorterForConversations)
                    self?.conversations = sortedItems
                    
                    if (onRefresh) {
                        self?.isConversationsRefreshing = false
                    } else {
                        self?.isConversationsLoading = false
                    }
                })
            .store(in: &cancellables)
    }
    
    func sorterForConversations(this: PersistentConversationDataItem, that: PersistentConversationDataItem) -> Bool {
        // Some conversations have null values so excluding from sorting
        if (this.dateCreated == nil){
            return false
        }
        if (that.dateCreated == nil){
            return true
        }
        
        let thisDate = this.lastMessageDate == nil ? this.dateCreated : this.lastMessageDate
        let thatDate = that.lastMessageDate == nil ? that.dateCreated : that.lastMessageDate
        
        return thisDate! > thatDate!
    }
    
    func loadAllConversations() async {
        guard let client = client.conversationsClient else {
            return
        }
        
        guard let conversations = client.myConversations() else {
            return
        }
        
        conversations.forEach { PersistentConversationDataItem.from(conversation: $0, inContext: coreDataManager.viewContext) }
        
        do {
            try await coreDataManager.saveContext()
        } catch {
            presentErrorToast(error, silent: true)
        }
    }
    
    func retrieveConversation(_ conversationSid: String) async throws -> TCHConversation {
        guard let client = client.conversationsClient else {
            throw DataFetchError.conversationsClientIsNotAvailable
        }
        
        let (result, conversation) = await client.conversation(withSidOrUniqueName: conversationSid)
        
        guard result.isSuccessful, let conversation else {
            throw DataFetchError.requiredDataCallsFailed
        }
        
        return conversation
    }
    
    func createAndJoinConversation(friendlyName: String?, completion: @escaping (Error?) -> Void) {
        let creationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName ?? "",
        ]
        
        guard let client = client.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }
        
        client.createConversation(options: creationOptions) { result, conversation in
            guard let conversation = conversation else {
                completion(result.error)
                return
            }
            
            conversation.join { result in
                completion(result.error)
            }
        }
    }
    
    func toggleMute(onConversation item: PersistentConversationDataItem) async {
        if let conversationSid = item.sid,
           let conversation = try? await retrieveConversation(conversationSid) {
            
            await coreDataManager.viewContext.perform {
                let isConversationMuted = item.muted
                conversation.setNotificationLevel(isConversationMuted ? .default : .muted) { result in
                    if (result.isSuccessful) {
                        self.conversationEventPublisher.send(isConversationMuted ? .notificationsTurnedOff : .notificationsTurnedOn)
                    }
                }
            }
        }
    }
    
    func renameConversation(sid: String, name: String?) async throws {
        let conversation = try await retrieveConversation(sid)
        
        let result = await conversation.setFriendlyName(name)
        
        if !result.isSuccessful {
            throw URLError(.badServerResponse)
        }
    }
    
    func leave(conversation item: PersistentConversationDataItem) async {
        if let conversationSid = item.sid, let conversation = try? await retrieveConversation(conversationSid) {
            let result = await conversation.leave()
            if result.isSuccessful {
                self.conversationEventPublisher.send(.leftConversation)
            } else {
                print("Failed to leave conversation")
            }
        }
    }
    
    // MARK: Typing
    @Published var typingParticipants: [String: Set<Participant>] = [:]
    func registerForTyping() {
        typingPublisher
            .sink(receiveValue: { typing in
                DispatchQueue.main.async {
                    switch typing {
                    case .startedTyping(let convo, let participant):
                        if var set = self.typingParticipants[convo] {
                            set.insert(participant)
                            self.typingParticipants[convo] = set
                        } else {
                            self.typingParticipants[convo] = [participant]
                        }
                    case .stoppedTyping(let convo, let participant):
                        if var set = self.typingParticipants[convo] {
                            set.remove(participant)
                            self.typingParticipants[convo] = set
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    enum TypingActivity {
        case startedTyping(conversationSid: String, participant: Participant)
        case stoppedTyping(conversationSid: String, participant: Participant)
    }
}

extension ConversationsManager: TwilioConversationsClientDelegate {
    // MARK: Client changes
    
    func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
        self.clientState = state
    }
    
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        self.client.conversationsClientTokenWillExpire(client)
    }
    
    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        self.client.conversationsClientTokenExpired(client)
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversationsError errorReceived: TCHError) {
        DispatchQueue.main.async {
            self.conversationsError = errorReceived
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == .failed {}
        if status == .completed {
            Task {
                await self.loadAllConversations()
            }
        }
    }
    
    // MARK: Conversation changes
    
    func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        print("Conversation added: \(String(describing: conversation.sid)) w/ name \(String(describing: conversation.friendlyName))")
        conversation.delegate = self
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try await coreDataManager.saveContext()
                print("Conversation upserted")
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        if let conversationSid = conversation.sid {
            PersistentConversationDataItem.deleteConversationsUnchecked([conversationSid], inContext: coreDataManager.viewContext)
            PersistentMessageDataItem.deleteAllMessagesByConversationSid([conversationSid], inContext: coreDataManager.viewContext)
            PersistentParticipantDataItem.deleteAllParticipantsByConversationSid([conversationSid], inContext: coreDataManager.viewContext)
            PersistentMediaDataItem.deleteAllMediaItemsByConversationSid([conversationSid], inContext: coreDataManager.viewContext)
        }
    }
    
    // MARK: Typing changes
    
    func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        let participant =  TCHAdapter.transform(from: participant)
        typingPublisher.send(.startedTyping(conversationSid: conversation.sid!, participant: participant))
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        let participant =  TCHAdapter.transform(from: participant)
        typingPublisher.send(.stoppedTyping(conversationSid: conversation.sid!, participant: participant))
    }
    
    // MARK: User changes
    
    //    func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated update: TCHUserUpdate) {
    //        if user.identity == myIdentity {
    //            myUser = user
    //        }
    //    }
}

extension ConversationsManager: TCHConversationDelegate {
    
    // MARK: Conversation changes
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated update: TCHConversationUpdate) {
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    // MARK: Message changes
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        if let _ = PersistentMessageDataItem.from(message: message, inConversation: conversation, withDirection: message.author == self.myUser?.identity ? .outgoing : .incoming, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        guard conversation.sid != nil else {
            return
        }
        
        if let _ = PersistentMessageDataItem.from(message: message, inConversation: conversation, withDirection: message.author == self.myUser?.identity ? .outgoing : .incoming, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
        
        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        guard let messageSid = message.sid else {
            return
        }
        
        PersistentMessageDataItem.deleteMessagesUnchecked([messageSid], inContext: coreDataManager.viewContext)
        
        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    // MARK: Client changes
    
    func conversationsClient(_ client: TwilioConversationsClient,
                             conversation: TCHConversation,
                             synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        guard conversation.synchronizationStatus.rawValue >= TCHConversationSynchronizationStatus.all.rawValue else {
            return
        }
        
        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    // MARK: Participant changes
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        if let _ = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
        
        // Update conversation participant stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
        if let _ = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
        
        // Update conversation participant stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
            Task {
                try? await coreDataManager.saveContext()
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        guard let conversationSid = conversation.sid,
              let participantSid = participant.sid else {
            return
        }
        
        PersistentParticipantDataItem.deleteParticipants([participantSid], inContext: coreDataManager.viewContext)
        
        if participant.identity == self.myUser?.identity {
            PersistentConversationDataItem.deleteConversationsUnchecked([conversationSid], inContext: coreDataManager.viewContext)
        } else {
            // Update conversation participant stats
            if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: coreDataManager.viewContext) {
                Task {
                    try? await coreDataManager.saveContext()
                }
            }
        }
    }
    
    func logOutHandler() {
        self.myUser = nil
        self.client.shutdown()
    }
}
