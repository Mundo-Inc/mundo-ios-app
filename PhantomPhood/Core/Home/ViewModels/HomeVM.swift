//
//  ForYouViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/16/23.
//

import Foundation
import SwiftUI

class HomeVM: LoadingSections, ObservableObject {
    static let dragAmountToRefresh: Double = 200.0
    
    /// Used for pull to referesh - Percentage
    @Published var draggedAmount: Double = .zero
    
    private let feedDM = FeedDM()
    private let userProfileDM = UserProfileDM()
    private let leaderboardDM = LeaderboardDM()
    private let reactionsDM = ReactionsDM()
    
    @Published var forYouItems: [FeedItem] = []
    @Published var followingItems: [FeedItem] = []
    @Published var isFeedEmpty: Bool = false
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var forYouItemOnViewPort: String? = nil
    @Published var followingItemOnViewPort: String? = nil
    
    @Published var leaderboard: [UserEssentials]? = nil
    
    private var followingPage: Int = 1
    private var forYouPage: Int = 1
    
    private var lastForYouRefereshTime: Date? = nil
    private var lastFollowingRefereshTime: Date? = nil
    
    var scrollFollowingToItem: ((String) -> Void)? = nil
    var scrollForYouToItem: ((String) -> Void)? = nil
    
    // MARK: - Following
    
    func updateFollowingData(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.fetchingFollowingData) else { return }
        
        if action == .refresh {
            followingPage = 1
        }
        
        setLoadingState(.fetchingFollowingData, to: true)
        
        defer {
            setLoadingState(.fetchingFollowingData, to: false)
        }
        
        do {
            let data = try await feedDM.getFeed(page: self.followingPage, type: .followings)
            
            await MainActor.run {
                if action == .refresh || self.followingItems.isEmpty {
                    self.followingItems = getClusteredFeedItems(data)
                } else {
                    self.followingItems.append(contentsOf: getClusteredFeedItems(data))
                }
                
                isFeedEmpty = self.followingItems.isEmpty
                
                if action == .refresh {
                    self.lastFollowingRefereshTime = .now
                    if let first = self.followingItems.first {
                        scrollFollowingToItem?(first.id)
                    }
                }
            }
            
            followingPage += 1
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: - For You
    
    func updateForYouData(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.fetchingForYouData) else { return }
        
        if action == .refresh {
            forYouPage = 1
        }
        
        setLoadingState(.fetchingForYouData, to: true)
        
        defer {
            setLoadingState(.fetchingForYouData, to: false)
        }
        
        do {
            let data = try await feedDM.getFeed(page: self.forYouPage, type: .forYou)
            
            await MainActor.run {
                if action == .refresh || self.forYouItems.isEmpty {
                    self.forYouItems = data
                } else {
                    self.forYouItems.append(contentsOf: data)
                }
                
                if action == .refresh {
                    self.lastForYouRefereshTime = .now
                    if let first = self.forYouItems.first {
                        scrollForYouToItem?(first.id)
                    }
                }
            }
            
            forYouPage += 1
        } catch {
            presentErrorToast(error)
        }
    }
    
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
    
    func followResourceUser(_ userId: String) async -> Result<UserProfileDM.FollowRequestStatus, Error>? {
        guard !loadingSections.contains(.followRequest(userId)) else { return nil }
        
        setLoadingState(.followRequest(userId), to: true)
        
        defer {
            setLoadingState(.followRequest(userId), to: false)
        }
        
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            return .success(status)
        } catch {
            presentErrorToast(error)
            return .failure(error)
        }
    }
    
    func followUser(_ userId: String) async -> Result<UserProfileDM.FollowRequestStatus, Error>? {
        guard !loadingSections.contains(.followRequest(userId)) else { return nil }
        
        setLoadingState(.followRequest(userId), to: true)
        
        defer {
            setLoadingState(.followRequest(userId), to: false)
        }
        
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            return .success(status)
        } catch {
            presentErrorToast(error)
            return .failure(error)
        }
    }
    
    /// update if more than 15 minutes has passed
    func updateFollowingIfNeeded() async {
        if let lastRefereshTime = lastFollowingRefereshTime, lastRefereshTime.addingTimeInterval(15 * 60) < .now {
            await self.updateFollowingData(.refresh)
        }
    }
    
    /// update if more than 15 minutes has passed
    func updateForYouIfNeeded() async {
        if let lastRefereshTime = lastForYouRefereshTime, lastRefereshTime.addingTimeInterval(15 * 60) < .now {
            await self.updateForYouData(.refresh)
        }
    }
    
    func addReaction(_ reaction: GeneralReactionProtocol, to feedItem: FeedItem) async -> Result<FeedItem, Error>? {
        guard !loadingSections.contains(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id)) else { return nil }
        
        HapticManager.shared.impact(style: .light)
        
        setLoadingState(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id), to: true)
        
        defer {
            setLoadingState(.addingReaction(symbol: reaction.reaction, activityId: feedItem.id), to: false)
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
        guard !loadingSections.contains(.removeingReaction(reactionId: reaction.id)) else { return nil }
        
        HapticManager.shared.impact(style: .light)
        
        setLoadingState(.removeingReaction(reactionId: reaction.id), to: true)
        
        defer {
            setLoadingState(.removeingReaction(reactionId: reaction.id), to: false)
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
    
    func getLeaderboardData() async {
        do {
            let data = try await leaderboardDM.fetchLeaderboard(page: 1)
            
            await MainActor.run {
                self.leaderboard = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func followLeaderboardUser(userId: String) async {
        guard !loadingSections.contains(.followRequest(userId)) else { return }
        
        setLoadingState(.followRequest(userId), to: true)
        
        defer {
            setLoadingState(.followRequest(userId), to: false)
        }
        
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            await MainActor.run {
                if let leaderboard, let userIndex = leaderboard.firstIndex(where: { $0.id == userId }) {
                    switch status {
                    case .following:
                        self.leaderboard![userIndex].setConnectionStatus(following: .following)
                    case .requested:
                        self.leaderboard![userIndex].setConnectionStatus(following: .requested)
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await self.updateFollowingData(.refresh)
                }
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case fetchingForYouData
        case fetchingFollowingData
        case startingConversation(with: String)
        case followRequest(String)
        case addingReaction(symbol: String, activityId: String)
        case removeingReaction(reactionId: String)
    }
}
