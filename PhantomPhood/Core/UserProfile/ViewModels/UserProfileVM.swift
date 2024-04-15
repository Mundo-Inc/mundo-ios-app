//
//  UserProfileVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class UserProfileVM: ObservableObject {
    private var id: String? = nil
    
    private let userProfileDM = UserProfileDM()
    private let conversationsDM = ConversationsDM()
    private let toastManager = ToastVM.shared
    
    @Published private(set) var loadingSections = Set<LoadingSection>()
    @Published private(set) var isFollowedByUser: Bool? = nil
    @Published private(set) var user: UserDetail?
    @Published private(set) var error: String?
    
    @Published var showActions = false
    @Published var blockStatus: BlockStatus? = nil
    
    init(id: String) {
        self.id = id
        
        Task {
            await fetchUser()
        }
    }
    
    init(username: String) {
        Task {
            await fetchUser(username: username)
        }
    }
    
    func fetchUser(username: String? = nil) async {
        self.loadingSections.insert(.fetchingUserData)
        if let id = self.id {
            do {
                let theUser = try await userProfileDM.fetch(id: id)
                self.user = theUser
                self.isFollowedByUser = theUser.connectionStatus.followedByUser
                self.error = nil
            } catch {
                self.error = error.localizedDescription
                guard let theError = error as? APIManager.APIError else { return }
                switch theError {
                case .serverError(let serverError):
                    if serverError.statusCode == 403 {
                        if serverError.message == "You have blocked this user" {
                            self.blockStatus = .isBlocked
                        } else {
                            self.blockStatus = .hasBlocked
                        }
                        self.user = nil
                        self.isFollowedByUser = nil
                    }
                    self.error = serverError.message
                case .decodingError(let decodingError):
                    self.error = decodingError.localizedDescription
                case .unknown:
                    print("Unknown error")
                }
            }
        } else if let username {
            do {
                let theUser = try await userProfileDM.fetch(username: username)
                self.id = theUser.id
                self.user = theUser
                self.isFollowedByUser = theUser.connectionStatus.followedByUser
                self.error = nil
            } catch {
                self.error = error.localizedDescription
                guard let theError = error as? APIManager.APIError else { return }
                switch theError {
                case .serverError(let serverError):
                    if serverError.statusCode == 403 {
                        if serverError.message == "You have blocked this user" {
                            self.blockStatus = .isBlocked
                        } else {
                            self.blockStatus = .hasBlocked
                        }
                        self.user = nil
                        self.isFollowedByUser = nil
                    }
                    self.error = serverError.message
                case .decodingError(let decodingError):
                    self.error = decodingError.localizedDescription
                case .unknown:
                    print("Unknown error")
                }
            }
        }
        self.loadingSections.remove(.fetchingUserData)
    }
    
    func follow() async {
        guard let id = self.id else { return }
        
        self.loadingSections.insert(.followOperation)
        do {
            try await userProfileDM.follow(id: id)
            self.isFollowedByUser = true
            HapticManager.shared.notification(type: .success)
        } catch {
            toastManager.toast(Toast(type: .error, title: "Failed", message: "Failed to follow \(user?.name ?? "this user")"))
        }
        self.loadingSections.remove(.followOperation)
    }
    
    func unfollow() async {
        guard let id = self.id else { return }
        
        self.loadingSections.insert(.followOperation)
        do {
            try await userProfileDM.unfollow(id: id)
            self.isFollowedByUser = false
            HapticManager.shared.notification(type: .success)
        } catch {
            toastManager.toast(Toast(type: .error, title: "Failed", message: "Failed to unfollow \(user?.name ?? "this user")"))
        }
        self.loadingSections.remove(.followOperation)
    }
    
    func block() async {
        guard let id = self.id else { return }
        
        self.loadingSections.insert(.blockOperation)
        do {
            try await userProfileDM.block(id: id)
            self.user = nil
            self.isFollowedByUser = nil
            self.blockStatus = .isBlocked
            
            HapticManager.shared.notification(type: .success)
        } catch {
            print(error)
        }
        self.loadingSections.remove(.blockOperation)
    }
    
    func unblock() async {
        guard let id = self.id else { return }
        
        self.loadingSections.insert(.blockOperation)
        do {
            try await userProfileDM.unblock(id: id)
            self.blockStatus = nil
            await fetchUser()
            
            HapticManager.shared.notification(type: .success)
        } catch {
            print(error)
        }
        self.loadingSections.remove(.blockOperation)
    }
    
    func startConversation() async {
        guard let id else { return }
        
        self.loadingSections.insert(.startingConversation)
        do {
            let conversation = try await conversationsDM.createConversation(with: id)
            
            HapticManager.shared.impact(style: .light)
            
            AppData.shared.goTo(.conversation(sid: conversation.sid, focusOnTextField: true))
        } catch {
            ToastVM.shared.toast(.init(type: .error, title: "Error", message: "Couldn't start a conversation with \(self.user?.name ?? "this user")"))
        }
        self.loadingSections.remove(.startingConversation)
    }
    
    // MARK: Enums
    
    enum BlockStatus {
        case isBlocked
        case hasBlocked
    }
    
    enum LoadingSection: Hashable {
        case fetchingUserData
        case startingConversation
        case blockOperation
        case followOperation
    }
}
