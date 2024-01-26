//
//  PlaceReviewsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation

@MainActor
class PlaceReviewsViewModel: ObservableObject {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    private let reactionsDM = ReactionsDM()
    
    let placeId: String
    
    init(placeId: String) {
        self.placeId = placeId
    }
    
    @Published var isLoading: Bool = false
    @Published var reviews: [PlaceReview] = []
    
    var page = 1
    func fetch(type: RefreshNewAction) async {
        if isLoading { return }
        
        guard let token = await auth.getToken() else { return }
        
        struct ReviewsResponse: Decodable {
            let success: Bool
            let total: Int
            let data: [PlaceReview]
        }
        
        isLoading = true
        
        if type == .refresh {
            page = 1
        }
        
        do {
            let data = try await apiManager.requestData("/places/\(placeId)/reviews?page=\(page)", token: token) as ReviewsResponse?
            if let data = data {
                if page == 1 {
                    reviews = data.data
                } else {
                    reviews.append(contentsOf: data.data)
                }
                page += 1
            }
        } catch {
            print(error)
        }
        
        isLoading = false
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol, to review: PlaceReview) async {
        guard let activityId = review.userActivityId else { return }
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: Date().ISO8601Format())
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
