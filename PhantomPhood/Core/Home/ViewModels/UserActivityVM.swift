//
//  UserActivityVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import Foundation

@MainActor
final class UserActivityVM: ObservableObject {
    private let userActivityDM = UserActivityDM()
    private let reactionsDM = ReactionsDM()
    
    @Published private(set) var data: FeedItem? = nil
    @Published private(set) var isLoading: Bool = false
    @Published var error: String? = nil
    
    func getActivity(_ id: String) async {
        self.isLoading = true
        do {
            let data = try await userActivityDM.getUserActivity(id)
            self.data = data
        } catch {
            self.error = error.localizedDescription
            print(error)
        }
        self.isLoading = false
    }
    
    /// Add reaction to item
    /// - Parameters:
    ///   - reaction: NewReaction - aanything that conforms to GeneralReactionProtocol
    ///   - item: FeedItem
    func addReaction(_ reaction: GeneralReactionProtocol) async {
        guard let data else { return }
        // add temporary reaction
        let tempUserReaction = UserReaction(id: "Temp", reaction: reaction.reaction, type: reaction.type, createdAt: Date().ISO8601Format())
        self.data?.addReaction(tempUserReaction)

        // add reaction to server
        do {
            let userReaction = try await reactionsDM.addReaction(type: reaction.type, reaction: reaction.reaction, for: data.id)

            // replace temporary reaction with server reaction
            self.data?.removeReaction(tempUserReaction)
            self.data?.addReaction(userReaction)
        } catch {
            // remove temp reaction
            self.data?.removeReaction(tempUserReaction)
        }
    }

    /// Remove reaction from item
    /// - Parameters:
    ///   - reaction: UserReaction
    ///   - item: FeedItem
    func removeReaction(_ reaction: UserReaction) async {
        // remove temporary reaction
        self.data?.removeReaction(reaction)

        // remove reaction from server
        do {
            try await reactionsDM.removeReaction(reactionId: reaction.id)
        } catch {
            // add temp reaction back
            self.data?.addReaction(reaction)
        }
    }
}
