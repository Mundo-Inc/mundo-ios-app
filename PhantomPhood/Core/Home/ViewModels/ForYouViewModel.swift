//
//  ForYouViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/16/23.
//

import Foundation

@MainActor
class ForYouViewModel: ObservableObject {
    let dataManager = FeedDataManager()
    
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
}
