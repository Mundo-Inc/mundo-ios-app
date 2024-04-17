//
//  LeaderboardVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class LeaderboardVM: ObservableObject {
    private let leaderboardDM = LeaderboardDM()
    
    @Published private(set) var isLoading = false
    @Published private(set) var list: [UserEssentials] = []
    
    private var page: Int = 1
    
    init() {
        Task {
            await fetchList(.refresh)
        }
    }
    
    func fetchList(_ action: RefreshNewAction) async {
        guard !isLoading else { return }
        
        self.isLoading = true
        
        if action == .refresh {
            page = 1
        }
        
        do {
            let data = try await leaderboardDM.fetchLeaderboard(page: page)
            if action == .refresh || self.list.isEmpty {
                self.list = data
            } else {
                self.list.append(contentsOf: data)
            }
            
            page += 1
        } catch {
            presentErrorToast(error)
        }
        self.isLoading = false
    }
    
    func loadMore(index: Int) async {
        let thresholdIndex = list.index(list.endIndex, offsetBy: -5)
        if index == thresholdIndex {
            await fetchList(.new)
        }
    }
}
