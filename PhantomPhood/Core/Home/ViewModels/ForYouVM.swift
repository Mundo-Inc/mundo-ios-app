//
//  ForYouViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/16/23.
//

import Foundation

@MainActor
class ForYouVM: ObservableObject {
    private let dataManager = FeedDM()
    private let reactionsDM = ReactionsDM()
    
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    
    var page: Int = 1
    
    init() {
        Task {
            await getForYou(.refresh)
        }
    }
    
    func getForYou(_ action: RefreshNewAction) async {
        guard !isLoading else { return }
        
        if action == .refresh {
            page = 1
        }
        
        do {
            self.isLoading = true
            let data = try await dataManager.getFeed(page: self.page, type: .forYou)
            if action == .refresh || self.items.isEmpty {
                self.items = data
            } else {
                self.items.append(contentsOf: data)
            }
            self.isLoading = false
            page += 1
        } catch {
            print(error)
        }
    }

    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, to item: FeedItem) async {
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: Date().ISO8601Format())
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
    func removeReaction(_ reaction: UserReaction, from item: FeedItem) async {
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
