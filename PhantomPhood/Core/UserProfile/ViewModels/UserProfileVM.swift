//
//  UserProfileVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class UserProfileVM: LoadingSections, ObservableObject {
    private let userProfileDM = UserProfileDM()
    private let userActivityDM = UserActivityDM()
    private let conversationsDM = ConversationsDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var activeTab: Tab = .posts
    
    @Published private(set) var user: UserDetail?
    @Published private(set) var error: String?
    
    @Published var posts: [FeedItem] = []
    
    @Published var showActions = false
    @Published var blockStatus: BlockStatus? = nil
    
    init(id: String) {
        Task {
            await fetchUser(id: id)
        }
    }
    
    init(username: String) {
        Task {
            await fetchUser(username: username)
        }
    }
    
    func fetchUser(username: String) async {
        guard !loadingSections.contains(.fetchingUserData) else { return }
        
        setLoadingState(.fetchingUserData, to: true)
        do {
            let theUser = try await userProfileDM.fetch(username: username)
            
            await MainActor.run {
                self.user = theUser
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = getErrorMessage(error)
                
                guard let theError = error as? APIManager.APIError else { return }
                
                if case .serverError(let serverError) = theError {
                    if serverError.statusCode == 403 {
                        if serverError.message == "You have blocked this user" {
                            self.blockStatus = .isBlocked
                        } else {
                            self.blockStatus = .hasBlocked
                        }
                        self.user = nil
                    }
                }
            }
        }
        setLoadingState(.fetchingUserData, to: false)
    }
    
    func fetchUser(id: String) async {
        guard !loadingSections.contains(.fetchingUserData) else { return }
        
        setLoadingState(.fetchingUserData, to: true)
        do {
            let theUser = try await userProfileDM.fetch(id: id)
            
            await MainActor.run {
                self.user = theUser
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = getErrorMessage(error)
                
                guard let theError = error as? APIManager.APIError else { return }
                
                if case .serverError(let serverError) = theError {
                    if serverError.statusCode == 403 {
                        if serverError.message == "You have blocked this user" {
                            self.blockStatus = .isBlocked
                        } else {
                            self.blockStatus = .hasBlocked
                        }
                        self.user = nil
                    }
                }
            }
        }
        setLoadingState(.fetchingUserData, to: false)
    }
    
    func follow() async {
        guard let id = self.user?.id, !loadingSections.contains(.followOperation) else { return }
        
        setLoadingState(.followOperation, to: true)
        do {
            let status = try await userProfileDM.follow(id: id)
            await MainActor.run {
                if self.user != nil {
                    switch status {
                    case .following:
                        self.user!.setConnectionStatus(following: .following)
                    case .requested:
                        self.user!.setConnectionStatus(following: .requested)
                    }
                }
            }
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.followOperation, to: false)
    }
    
    func unfollow() async {
        guard let id = self.user?.id, !loadingSections.contains(.followOperation) else { return }
        
        setLoadingState(.followOperation, to: true)
        do {
            try await userProfileDM.unfollow(id: id)
            await MainActor.run {
                if self.user != nil {
                    self.user!.setConnectionStatus(following: .notFollowing)
                }
            }
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.followOperation, to: false)
    }
    
    func removeFollower() async {
        guard let id = self.user?.id, !loadingSections.contains(.removeFollower) else { return }
        
        setLoadingState(.removeFollower, to: true)
        do {
            try await userProfileDM.removeFollower(id: id)
            await MainActor.run {
                if self.user != nil {
                    self.user!.setConnectionStatus(followedBy: .notFollowing)
                }
            }
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.removeFollower, to: false)
    }
    
    func block() async {
        guard let id = self.user?.id, !loadingSections.contains(.blockOperation) else { return }
        
        setLoadingState(.blockOperation, to: true)
        do {
            try await userProfileDM.block(id: id)
            
            await MainActor.run {
                self.user = nil
                self.blockStatus = .isBlocked
            }
            
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.blockOperation, to: false)
    }
    
    func unblock() async {
        guard let id = self.user?.id, !loadingSections.contains(.blockOperation) else { return }
        
        setLoadingState(.blockOperation, to: true)
        do {
            try await userProfileDM.unblock(id: id)
            
            await MainActor.run {
                self.blockStatus = nil
            }
            
            await fetchUser(id: id)
            
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.blockOperation, to: false)
    }
    
    func startConversation() async {
        guard let id = self.user?.id, !loadingSections.contains(.startingConversation) else { return }
        
        setLoadingState(.startingConversation, to: true)
        do {
            let conversation = try await conversationsDM.createConversation(with: id)
            
            HapticManager.shared.impact(style: .light)
            
            AppData.shared.goTo(.conversation(sid: conversation.sid, focusOnTextField: true))
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.startingConversation, to: false)
    }
    
    private var userPostsPagination: Pagination? = nil
    func getPosts(_ requestType: RefreshNewAction) async {
        guard let id = self.user?.id, !loadingSections.contains(.gettingPosts) else { return }
        
        if requestType == .refresh {
            userPostsPagination = nil
        } else if let userPostsPagination, !userPostsPagination.hasMore {
            return
        }
        
        setLoadingState(.gettingPosts, to: true)
        do {
            let page = (userPostsPagination?.page ?? 0) + 1
            
            let result = try await userActivityDM.getUserActivities(id, page: page, activityTypes: [.newCheckin, .newReview, .newHomemade], limit: 21)
            
            userPostsPagination = result.pagination
            
            await MainActor.run {
                if requestType == .new {
                    self.posts.append(contentsOf: result.data)
                } else {
                    self.posts = result.data
                }
            }
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.gettingPosts, to: false)
    }
    
    func loadMorePosts(currentItem: FeedItem) async {
        guard !loadingSections.contains(.gettingPosts) else { return }
        
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await getPosts(.new)
        }
    }
    
    // MARK: Enums
    
    enum Tab: Hashable, CaseIterable {
        case posts
        case achievements
        case lists
        case gifts
        
        var title: String {
            switch self {
            case .posts:
                return "Posts"
            case .achievements:
                return "Achievements"
            case .lists:
                return "Lists"
            case .gifts:
                return "Gifts"
            }
        }
        
        var iconSystemName: String {
            switch self {
            case .posts:
                return "app.connected.to.app.below.fill"
            case .achievements:
                return "crown"
            case .lists:
                return "list.star"
            case .gifts:
                return "gift"
            }
        }
    }
    
    enum BlockStatus {
        case isBlocked
        case hasBlocked
    }
    
    enum LoadingSection: Hashable {
        case fetchingUserData
        case startingConversation
        case blockOperation
        case followOperation
        case removeFollower
        case gettingPosts
    }
}
