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
    
    var page: Int = 1
    
    init() {
        Task {
            await getFeed()
        }
    }
    
    func getFeed() async {
        if isLoading {
            return
        }
        do {
            self.isLoading = true
            let data = try await dataManager.getFeed(page: self.page)
            if self.feedItems.isEmpty {
                self.feedItems = data
            } else {
                self.feedItems.append(contentsOf: data)
            }
            self.isLoading = false
            print(page)
            page += 1
        } catch {
            print(error)
        }
    }
}
