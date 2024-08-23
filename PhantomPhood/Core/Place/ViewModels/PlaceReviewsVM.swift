//
//  PlaceReviewsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI

class PlaceReviewsVM: ObservableObject, LoadingSections {
    private let reactionsDM = ReactionsDM()
    private let placeDM = PlaceDM()
    
    private let placeVM: PlaceVM
    
    init(placeVM: PlaceVM) {
        self.placeVM = placeVM
    }
    
    enum LoadingSection: Hashable {
        case refresh
        case new
        case fetchingGoogleReviews
        case fetchingYelpReviews
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var reviews: [PlaceReview] = []
    @Published var googleReviews: [GoogleReview]? = nil
    @Published var yelpReviews: [YelpReview]? = nil
    @Published var total: Int? = nil
    
    private var pagination: Pagination? = nil
    
    func fetch(_ type: RefreshNewAction) async {
        guard let placeId = placeVM.place?.id, !loadingSections.contains(.new) && !loadingSections.contains(.refresh) else { return }

        if type == .refresh {
            pagination = nil
            setLoadingState(.refresh, to: true)
        } else if let pagination, !pagination.hasMore {
            return
        } else {
            setLoadingState(.new, to: true)
        }
        
        defer {
            switch type {
            case .refresh:
                setLoadingState(.refresh, to: false)
            case .new:
                setLoadingState(.new, to: false)
            }
        }
        
        do {
            let page = (pagination?.page ?? 0) + 1
            
            let data = try await placeDM.getReviews(id: placeId, page: page)
            
            await MainActor.run {
                self.total = data.pagination.totalCount
                if page == 1 {
                    reviews = data.data
                } else {
                    reviews.append(contentsOf: data.data)
                }
            }
            
            pagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
    }
    
    func fetchGooglePlacesReviews() async {
        guard let placeId = placeVM.place?.id, !loadingSections.contains(.fetchingGoogleReviews), googleReviews == nil else { return }
        
        setLoadingState(.fetchingGoogleReviews, to: true)
        
        defer {
            setLoadingState(.fetchingGoogleReviews, to: false)
        }

        do {
            let data = try await placeDM.getGooglePlacesReviews(id: placeId)
            
            await MainActor.run {
                self.googleReviews = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func fetchYelpReviews() async {
        guard let placeId = placeVM.place?.id, !loadingSections.contains(.fetchingYelpReviews), googleReviews == nil else { return }
        
        setLoadingState(.fetchingYelpReviews, to: true)
        
        defer {
            setLoadingState(.fetchingYelpReviews, to: false)
        }
        
        do {
            let data = try await placeDM.getYelpReviews(id: placeId)
            
            await MainActor.run {
                self.yelpReviews = data
            }
        } catch {
            presentErrorToast(error)
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
        
        await MainActor.run {
            self.reviews = self.reviews.map({ i in
                if i.id == review.id {
                    var newItem = i
                    newItem.addReaction(tempUserReaction)
                    return newItem
                }
                return i
            })
        }

        // add reaction to server
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: activityId)

            await MainActor.run {
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
            }
        } catch {
            HapticManager.shared.impact(style: .light)
            // remove temp reaction
            
            await MainActor.run {
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
    }

    /// Remove reaction from item
    /// - Parameters:
    ///   - reaction: UserReaction
    ///   - item: FeedItem
    func removeReaction(_ reaction: UserReaction, from review: PlaceReview) async {
        await MainActor.run {
            // remove temporary reaction
            self.reviews = self.reviews.map({ i in
                if i.id == review.id {
                    var newItem = i
                    newItem.removeReaction(reaction)
                    return newItem
                }
                return i
            })
        }

        // remove reaction from server
        do {
            try await reactionsDM.removeReaction(reactionId: reaction.id)
        } catch {
            await MainActor.run {
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
}
