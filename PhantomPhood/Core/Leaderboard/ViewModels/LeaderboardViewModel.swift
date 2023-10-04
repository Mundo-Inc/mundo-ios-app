//
//  LeaderboardViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class LeaderboardViewModel: ObservableObject {
    private let dataManager = LeaderboardDataManager()
    
    @Published private(set) var isLoading = false
    @Published private(set) var list: [User] = []
    @Published private(set) var error: String?
    
    var page: Int = 1
    
    enum GetLeaderboardAction {
        case refresh
        case new
    }
    
    init() {
        Task {
            await fetchList(.refresh)
        }
    }
    
    func fetchList(_ action: GetLeaderboardAction) async {
        if action == .refresh {
            page = 1
        }
        
        if isLoading {
            return
        }
        
        self.isLoading = true
        do {
            let data = try await dataManager.fetchLeaderboard(page: page)
            
            if action == .refresh || self.list.isEmpty {
                self.list = data
            } else {
                self.list.append(contentsOf: data)
            }
            
            page += 1
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
        self.isLoading = false
    }
        
    func loadMore(currentItem item: User) async {
        let thresholdIndex = list.index(list.endIndex, offsetBy: -5)
        if list.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            await fetchList(.new)
        }
    }
}
