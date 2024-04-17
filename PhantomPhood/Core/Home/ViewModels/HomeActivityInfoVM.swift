//
//  HomeActivityInfoVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import Foundation

@MainActor
final class HomeActivityInfoVM: ObservableObject {
    
    static let shared = HomeActivityInfoVM()
    
    private init() {}
    
    @Published var data: FeedItem?
    var handleAddReaction: (EmojisManager.Emoji) -> Void = { _ in }
    
    func show(_ feedItem: FeedItem, handleAddReaction: @escaping (_ reaction: EmojisManager.Emoji) -> Void) {
        self.data = feedItem
        self.handleAddReaction = handleAddReaction
    }
    
    func reset() {
        self.handleAddReaction = { _ in }
    }
    
    enum LoadingSection: Hashable {
        case followRequest(String)
    }
}
