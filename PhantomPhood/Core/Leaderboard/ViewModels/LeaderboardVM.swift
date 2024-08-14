//
//  LeaderboardVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

class LeaderboardVM: ObservableObject, LoadingSections {
    private let leaderboardDM = LeaderboardDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published private(set) var list: [UserEssentials] = []
    
    private var page: Int = 1
    
    init() {
        Task {
            await fetchList(.refresh)
        }
    }
    
    private var pagination: Pagination? = nil
    
    func fetchList(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.fetchLeaderboard) else { return }
        
        setLoadingState(.fetchLeaderboard, to: true)
        
        defer {
            setLoadingState(.fetchLeaderboard, to: false)
        }
        
        if action == .refresh {
            page = 1
        }
        
        do {
            let data = try await leaderboardDM.fetchLeaderboard(page: page)
            
            await MainActor.run {
                if action == .refresh || self.list.isEmpty {
                    self.list = data
                } else {
                    self.list.append(contentsOf: data)
                }
            }
            
            page += 1
        } catch {
            presentErrorToast(error)
        }
    }
    
    func loadMore(index: Int) async {
        guard !loadingSections.contains(.fetchLeaderboard) else { return }
        
        let thresholdIndex = list.index(list.endIndex, offsetBy: -5)
        if index == thresholdIndex {
            await fetchList(.new)
        }
    }
    
    enum LoadingSection: Hashable {
        case fetchLeaderboard
    }
}
