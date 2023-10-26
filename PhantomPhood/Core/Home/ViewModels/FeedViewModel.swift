//
//  FeedViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    let dataManager = FeedDataManager()
    
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading: Bool = false
    @Published var endReached: Bool = false
    
    @Published private(set) var isFollowingNabeel: Bool? = nil
    @Published var nabeel: UserProfile? = nil
    @Published var isRequestingFollow = false
    
    var page: Int = 1
    
    init() {
        Task {
            await getFeed(.refresh)
        }
    }
    
    enum GetFeedAction {
        case refresh
        case new
    }
    
    func getFeed(_ action: GetFeedAction) async {
        if action == .refresh {
            page = 1
        }
        
        if isLoading {
            return
        }
        do {
            self.isLoading = true
            let data = try await dataManager.getFeed(page: self.page)
            if action == .refresh || self.feedItems.isEmpty {
                self.feedItems = data
            } else {
                self.feedItems.append(contentsOf: data)
            }
            self.isLoading = false
            page += 1
        } catch {
            print(error)
        }
    }
    
    func loadMore(currentItem item: FeedItem) async {
        let thresholdIndex = feedItems.index(feedItems.endIndex, offsetBy: -5)
        if feedItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
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
}
