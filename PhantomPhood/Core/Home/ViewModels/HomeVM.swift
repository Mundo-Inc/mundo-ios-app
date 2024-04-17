//
//  ForYouViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/16/23.
//

import Foundation
import SwiftUI

@MainActor
class HomeVM: ObservableObject {
    static let dragAmountToRefresh: Double = 200.0
    
    /// Used for pull to referesh - Percentage
    @Published var draggedAmount: Double = .zero
    
    private let feedDM = FeedDM()
    private let userProfileDM = UserProfileDM()
    private let leaderboardDM = LeaderboardDM()
    private let reactionsDM = ReactionsDM()
    private let conversationsDM = ConversationsDM()
    
    @Published var forYouItems: [FeedItem] = []
    @Published var followingItems: [FeedItem] = []
    @Published var isFeedEmpty: Bool = false
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var forYouItemOnViewPort: String? = nil
    @Published var followingItemOnViewPort: String? = nil
    
    @Published var leaderboard: [UserEssentials]? = nil
    
    private var followingPage: Int = 1
    private var forYouPage: Int = 1
    
    // MARK: - General
    
    func startConversation(with userId: String) async {
        self.loadingSections.insert(.startingConversation)
        do {
            let conversation = try await conversationsDM.createConversation(with: userId)
            
            HapticManager.shared.impact(style: .light)
            
            AppData.shared.goTo(.conversation(sid: conversation.sid, focusOnTextField: true))
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.startingConversation)
    }
    
    // MARK: - Following
    
    func updateFollowingData(_ action: RefreshNewAction) async {
        guard !self.loadingSections.contains(.fetchingFollowingData) else { return }
        
        if action == .refresh {
            followingPage = 1
        }
        
        self.loadingSections.insert(.fetchingFollowingData)
        do {
            let data = try await feedDM.getFeed(page: self.followingPage, type: .followings)
            
            if action == .refresh || self.followingItems.isEmpty {
                self.followingItems = getClusteredFeedItems(data)
            } else {
                self.followingItems.append(contentsOf: getClusteredFeedItems(data))
            }
            
            isFeedEmpty = self.followingItems.isEmpty
            
            followingPage += 1
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.fetchingFollowingData)
    }
    
    // MARK: - For You
    
    func updateForYouData(_ action: RefreshNewAction) async {
        guard !self.loadingSections.contains(.fetchingForYouData) else { return }
        
        if action == .refresh {
            forYouPage = 1
        }
        
        self.loadingSections.insert(.fetchingForYouData)
        do {
            let data = try await feedDM.getFeed(page: self.forYouPage, type: .forYou)
            
            if action == .refresh || self.forYouItems.isEmpty {
                self.forYouItems = data
            } else {
                self.forYouItems.append(contentsOf: data)
            }
            
            forYouPage += 1
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.fetchingForYouData)
    }
    
    func getClusteredFeedItems(_ feedItems: [FeedItem]) -> [FeedItem] {
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
    
    func followResourceUser(item: Binding<FeedItem>, userId: String) async {
        self.loadingSections.insert(.followRequest(userId))
        do {
            try await userProfileDM.follow(id: userId)
            
            item.wrappedValue.followFromResourceUsers(userId: userId)
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.followRequest(userId))
    }
    
    func followUser(item: Binding<FeedItem>) async {
        self.loadingSections.insert(.followRequest(item.wrappedValue.user.id))
        do {
            try await userProfileDM.follow(id: item.wrappedValue.user.id)
            item.wrappedValue.user.setFollowedByUserStatus(true)
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.followRequest(item.wrappedValue.user.id))
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, to item: Binding<FeedItem>) async {
        HapticManager.shared.impact(style: .light)
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: .now)
        item.wrappedValue.addReaction(tempUserReaction)
        
        // add reaction to server
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: item.id)
            
            // replace temporary reaction with server reaction
            item.wrappedValue.removeReaction(tempUserReaction)
            item.wrappedValue.addReaction(userReaction)
        } catch {
            HapticManager.shared.impact(style: .light)
            // remove temp reaction
            item.wrappedValue.removeReaction(tempUserReaction)
        }
    }
    
    /// Remove reaction from item
    /// - Parameters:
    ///   - reaction: UserReaction
    ///   - item: FeedItem
    func removeReaction(_ reaction: UserReaction, from item: Binding<FeedItem>) async {
        // remove temporary reaction
        item.wrappedValue.removeReaction(reaction)
        
        // remove reaction from server
        do {
            try await reactionsDM.removeReaction(reactionId: reaction.id)
        } catch {
            // add temp reaction back
            item.wrappedValue.addReaction(reaction)
        }
    }
    
    func getLeaderboardData() async {
        do {
            self.leaderboard = try await leaderboardDM.fetchLeaderboard(page: 1)
        } catch {
            presentErrorToast(error)
        }
    }
    
    func followLeaderboardUser(userId: String) async {
        self.loadingSections.insert(.followRequest(userId))
        do {
            try await userProfileDM.follow(id: userId)
            
            if let leaderboard, let userIndex = leaderboard.firstIndex(where: { $0.id == userId }) {
                self.leaderboard![userIndex].setFollowedByUserStatus(true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await self.updateFollowingData(.refresh)
                }
            }
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.followRequest(userId))
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case fetchingForYouData
        case fetchingFollowingData
        case startingConversation
        case followRequest(String)
    }
}
