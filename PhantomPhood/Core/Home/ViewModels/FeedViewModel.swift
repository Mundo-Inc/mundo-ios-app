//
//  FeedViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    private let dataManager = FeedDM()
    private let reactionsDM = ReactionsDM()
    
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    
    @Published private(set) var isFollowingNabeel: Bool? = nil
    @Published var nabeel: UserProfile? = nil
    @Published var isRequestingFollow = false
    
    var page: Int = 1
    
    init() {
        Task {
            await getFeed(.refresh)
        }
    }
    
    func getFeed(_ action: RefreshNewAction) async {
        guard !isLoading else { return }
        
        if action == .refresh {
            page = 1
        }
        
        do {
            self.isLoading = true
            let data = try await dataManager.getFeed(page: self.page, type: .followings)
            if action == .refresh || self.items.isEmpty {
                self.items = data
            } else {
                self.items.append(contentsOf: data)
            }
            self.isLoading = false
            if self.items.isEmpty && data.isEmpty {
                await getNabeel()
            }
            page += 1
        } catch {
            print(error)
        }
    }
    
    func loadMore(currentIndex: Int) async {
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if currentIndex == thresholdIndex {
            await getFeed(.new)
        }
    }
    
    func getNabeel() async {
        do {
            let data = try await dataManager.getNabeel()
            self.nabeel = data
            self.isFollowingNabeel = data.isFollowing
        } catch {
            print(error)
        }
    }
    
    func followNabeel() async {
        self.isRequestingFollow = true
        do {
            try await dataManager.followNabeel()
            self.isFollowingNabeel = true
            await getFeed(.refresh)
        } catch {
            print(error)
        }
        self.isRequestingFollow = false
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, _ item: FeedItem) async {
        // add temporary reaction
        let tempUserReaction = UserReaction(_id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: Date().ISO8601Format())
        self.items = self.items.map({ i in
            if i.id == item.id {
                var newItem = i
                newItem.addReaction(tempUserReaction)
                return newItem
            }
            return i
        })
        
        // add reaction to server
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: item.id)
            
            // replace temporary reaction with server reaction
            self.items = self.items.map({ i in
                if i.id == item.id {
                    var newItem = i
                    newItem.removeReaction(tempUserReaction)
                    newItem.addReaction(userReaction)
                    return newItem
                }
                return i
            })
        } catch {
            // remove temp reaction
            self.items = self.items.map({ i in
                if i.id == item.id {
                    var newItem = i
                    newItem.removeReaction(tempUserReaction)
                    return newItem
                }
                return i
            })
        }
    }
    
    /// Remove reaction from item
    /// - Parameters:
    ///   - reaction: UserReaction
    ///   - item: FeedItem
    func removeReaction(_ reaction: UserReaction, _ item: FeedItem) async {
        // remove temporary reaction
        self.items = self.items.map({ i in
            if i.id == item.id {
                var newItem = i
                newItem.removeReaction(reaction)
                return newItem
            }
            return i
        })
        
        // remove reaction from server
        do {
            try await reactionsDM.removeReaction(reactionId: reaction.id)
        } catch {
            // add temp reaction back
            self.items = self.items.map({ i in
                if i.id == item.id {
                    var newItem = i
                    newItem.addReaction(reaction)
                    return newItem
                }
                return i
            })
        }
    }
}
