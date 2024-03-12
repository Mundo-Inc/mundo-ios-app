//
//  ProfileActivityVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation
import SwiftUI

@MainActor
class ProfileActivitiesVM: ObservableObject {
    private let auth = Authentication.shared
    private let reactionsDM = ReactionsDM()
    private let userActivityDM = UserActivityDM()

    @Published var activityType: FeedItemActivityType
    @Published var isactivityTypePresented = false
    @Published var isLoading = false
    @Published var items: [FeedItem] = []
    @Published var total: Int? = nil
    
    private let userId: UserIdEnum?
    
    init(userId: UserIdEnum?, activityType: FeedItemActivityType) {
        self.userId = userId
        self.activityType = activityType
        
        Task {
            await self.getActivities(.refresh)
        }
    }
    
    var page = 1
    
    func getActivities(_ type: RefreshNewAction) async {
        var uid: String?
        
        switch userId {
        case .currentUser:
            uid = auth.currentUser?.id
        case .withId(let theId):
            uid = theId
        case nil:
            uid = nil
        }
        
        guard let uid else { return }
        
        if type == .refresh {
            self.page = 1
            self.total = nil
        } else {
            if let total, items.count >= total {
                return
            }
        }
        
        self.isLoading = true
        
        do {
            let data = try await userActivityDM.getUserActivities(uid, page: self.page, activityType: activityType)
            
            switch type {
            case .refresh:
                self.items = data.data
            case .new:
                self.items.append(contentsOf: data.data)
            }
            
            self.total = data.pagination.totalCount
            self.page += 1
        } catch {
            print(error)
        }
        
        self.isLoading = false
    }
    
    func loadMore(currentIndex: Int) async {
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if currentIndex == thresholdIndex {
            await getActivities(.new)
        }
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, _ item: FeedItem) async {
        HapticManager.shared.impact(style: .light)
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: .now)
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
            HapticManager.shared.impact(style: .light)
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
