//
//  PlaceReviewsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI

@MainActor
class PlaceReviewsVM: ObservableObject {
    private let reactionsDM = ReactionsDM()
    private let placeDM = PlaceDM()
    
    private let placeVM: PlaceVM
    
    init(placeVM: PlaceVM) {
        self.placeVM = placeVM
    }
    
    enum LoadingSection: Hashable {
        case refresh
        case new
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var reviews: [PlaceReview] = []
    @Published var total: Int? = nil
    
    var page = 1
    func fetch(_ type: RefreshNewAction) async {
        guard let placeId = placeVM.place?.id, !loadingSections.contains(.new) && !loadingSections.contains(.refresh) else { return }

        if type == .refresh {
            page = 1
            loadingSections.insert(.refresh)
        } else {
            loadingSections.insert(.new)
        }
        
        do {
            let data = try await placeDM.getReviews(id: placeId, page: page)
            self.total = data.total
            if page == 1 {
                reviews = data.data
            } else {
                reviews.append(contentsOf: data.data)
            }
            page += 1
        } catch {
            print(error)
        }
        if type == .refresh {
            loadingSections.remove(.refresh)
        } else {
            loadingSections.remove(.new)
        }
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, to review: PlaceReview) async {
        guard let activityId = review.userActivityId else { return }
        HapticManager.shared.impact(style: .light)
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: .now)
        self.reviews = self.reviews.map({ i in
            if i.id == review.id {
                var newItem = i
                newItem.addReaction(tempUserReaction)
                return newItem
            }
            return i
        })

        // add reaction to server
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: activityId)

            // replace temporary reaction with server reaction
            self.reviews = self.reviews.map({ i in
                if i.id == review.id {
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
            self.reviews = self.reviews.map({ i in
                if i.id == review.id {
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
    func removeReaction(_ reaction: UserReaction, from review: PlaceReview) async {
        // remove temporary reaction
        self.reviews = self.reviews.map({ i in
            if i.id == review.id {
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
            self.reviews = self.reviews.map({ i in
                if i.id == review.id {
                    var newItem = i
                    newItem.addReaction(reaction)
                    return newItem
                }
                return i
            })
        }
    }
}
