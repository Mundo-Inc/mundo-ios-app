//
//  UserProfileVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation
import SwiftUI

final class UserProfileVM: LoadingSections, Equatable, Hashable {
    static func == (lhs: UserProfileVM, rhs: UserProfileVM) -> Bool {
        true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    // MARK: Data Managers
    
    private let userProfileDM = UserProfileDM()
    private let userActivityDM = UserActivityDM()
    private let reactionsDM = ReactionsDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var activityLoadingSections = Set<ActivityLoadingSection>()
    
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
    
    /// For activity view
    @Published var itemOnViewPort: String? = nil
    /// Used for pull to referesh - Percentage
    @Published var draggedAmount: Double = .zero
    @Published var activityType: TypeOptions = .defaultOptions {
        didSet {
            Task {
                await getPosts(.refresh)
            }
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
        ToastVM.shared.toast(Toast(type: .info, title: "Messaging is disabled", message: "We're improving messaging system and it's temporarily disabled"))
    }
    
    private var userPostsPagination: Pagination? = nil
    func getPosts(_ requestType: RefreshNewAction) async {
        guard let id = self.user?.id, !activityLoadingSections.contains(.gettingPosts) else { return }
        
        if requestType == .refresh {
            userPostsPagination = nil
        } else if let userPostsPagination, !userPostsPagination.hasMore {
            return
        }
        
        setActivityLoadingState(.gettingPosts, to: true)
        
        defer {
            setActivityLoadingState(.gettingPosts, to: false)
        }
        
        do {
            let page = (userPostsPagination?.page ?? 0) + 1
            
            let result = try await userActivityDM.getUserActivities(id, page: page, activityTypes: activityType.types, limit: 21)
            
            userPostsPagination = result.pagination
            
            await MainActor.run {
                if requestType == .refresh || self.posts.isEmpty {
                    self.posts = getClusteredFeedItems(result.data)
                } else {
                    self.posts.append(contentsOf: getClusteredFeedItems(result.data))
                }
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func loadMorePosts(currentItem: FeedItem) async {
        guard !activityLoadingSections.contains(.gettingPosts) else { return }
        
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await getPosts(.new)
        }
    }
    
    // MARK: Enums
    
    enum Tab: Hashable, CaseIterable {
        case posts
        case checkIns
        case achievements
        case lists
        case gifts
        
        var title: String {
            return switch self {
            case .posts:
                "Posts"
            case .checkIns:
                "Check Ins"
            case .achievements:
                "Achievements"
            case .lists:
                "Lists"
            case .gifts:
                "Gifts"
            }
        }
        
        var iconSystemName: String {
            return switch self {
            case .posts:
                "app.connected.to.app.below.fill"
            case .checkIns:
                "mappin.and.ellipse"
            case .achievements:
                "crown"
            case .lists:
                "list.star"
            case .gifts:
                "gift"
            }
        }
        
        var disabled: Bool {
            self == .gifts
        }
    }
    
    enum TypeOptions: String, CaseIterable {
        case defaultOptions
        case reviews
        case checkIns
        case homemades
        case following
        case recommends
        
        var types: [FeedItemActivityType] {
            switch self {
            case .defaultOptions:
                [.newCheckin, .newReview, .newHomemade]
            case .reviews:
                [.newReview]
            case .checkIns:
                [.newCheckin]
            case .homemades:
                [.newHomemade]
            case .following:
                [.following]
            case .recommends:
                [.newRecommend]
            }
        }
        
        var title: String {
            switch self {
            case .defaultOptions:
                "Summary"
            case .reviews:
                "Reviews"
            case .checkIns:
                "Check Ins"
            case .homemades:
                "Homemade"
            case .following:
                "Following"
            case .recommends:
                "Recommends"
            }
        }
    }
    
    enum BlockStatus {
        case isBlocked
        case hasBlocked
    }
    
    enum LoadingSection: Hashable {
        case fetchingUserData
        case blockOperation
        case followOperation
        case removeFollower
        case startingConversation
    }
}

extension UserProfileVM: ActivityItemVM {
    private func getClusteredFeedItems(_ feedItems: [FeedItem]) -> [FeedItem] {
        var result: [FeedItem] = []
        
        var skips = Set<String>()
        
        for item in feedItems {
            guard !skips.contains(item.id) else { continue }
            
            if item.activityType == .following {
                var newItem = item
                newItem.resource = .users(feedItems.filter({ $0.user.id == item.user.id && $0.activityType == item.activityType }).compactMap({ f in
                    switch f.resource {
                    case .user(let userEssentials):
                        skips.insert(f.id)
                        return userEssentials
                    default:
                        return nil
                    }
                }))
                
                result.append(newItem)
            } else {
                result.append(item)
            }
        }
        
        return result
    }
    
    func addReaction(_ reaction: GeneralReactionProtocol, to feedItem: FeedItem) async -> Result<FeedItem, Error>? {
        guard !activityLoadingSections.contains(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id)) else { return nil }
        
        HapticManager.shared.impact(style: .light)
        
        setActivityLoadingState(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id), to: true)
        
        defer {
            setActivityLoadingState(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id), to: false)
        }
        
        var updatedFeedItem = feedItem
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: feedItem.id)
            
            updatedFeedItem.addReaction(userReaction)
            return .success(updatedFeedItem)
        } catch {
            return .failure(error)
        }
    }
    
    func removeReaction(_ reaction: UserReaction, from feedItem: FeedItem) async -> Result<FeedItem, Error>? {
        guard !activityLoadingSections.contains(.removeingReaction(reactionId: reaction.id)) else { return nil }
        
        HapticManager.shared.impact(style: .light)
        
        setActivityLoadingState(.removeingReaction(reactionId: reaction.id), to: true)
        
        defer {
            setActivityLoadingState(.removeingReaction(reactionId: reaction.id), to: false)
        }
        
        var updatedFeedItem = feedItem
        do {
            try await reactionsDM.removeReaction(reactionId: reaction.id)
            
            updatedFeedItem.removeReaction(reaction)
            return .success(updatedFeedItem)
        } catch {
            return .failure(error)
        }
    }
    
    func followUser(_ userId: String) async -> Result<UserProfileDM.FollowRequestStatus, Error>? {
        guard !activityLoadingSections.contains(.followRequest(userId)) else { return nil }
        
        setActivityLoadingState(.followRequest(userId), to: true)
        
        defer {
            setActivityLoadingState(.followRequest(userId), to: false)
        }
        
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            return .success(status)
        } catch {
            presentErrorToast(error)
            return .failure(error)
        }
    }
    
    func followResourceUser(_ userId: String) async -> Result<UserProfileDM.FollowRequestStatus, Error>? {
        guard !activityLoadingSections.contains(.followRequest(userId)) else { return nil }
        
        setActivityLoadingState(.followRequest(userId), to: true)
        
        defer {
            setActivityLoadingState(.followRequest(userId), to: false)
        }
        
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            return .success(status)
        } catch {
            presentErrorToast(error)
            return .failure(error)
        }
    }
}
