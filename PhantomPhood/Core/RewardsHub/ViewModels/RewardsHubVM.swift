//
//  RewardsHubVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI

@MainActor
final class RewardsHubVM: ObservableObject {
    private var pcVM = PhantomCoinsVM.shared
    private var rewardsDM = RewardsDM()
    
    enum LoadingSection: Hashable {
        case dailyReward
        case missions
        case mission(String)
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var missions: [Mission]? = nil
    
    func claimDailyReward() async {
        guard !pcVM.hasClaimedToday && !loadingSections.contains(.dailyReward) else { return }
        
        self.loadingSections.insert(.dailyReward)
        do {
            try await rewardsDM.claimDailyRewards()
            await pcVM.refresh()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } catch {
            print(error)
        }
        self.loadingSections.remove(.dailyReward)
    }
    
    func getMissions() async {
        guard !loadingSections.contains(.missions) else { return }
        
        self.loadingSections.insert(.missions)
        do {
            let data = try await rewardsDM.getMissions()
            self.missions = data
        } catch {
            print(error)
        }
        self.loadingSections.remove(.missions)
    }
    
    func claimMissions(id: String) async {
        guard !loadingSections.contains(.missions) && !loadingSections.contains(.mission(id)) else { return }
        
        self.loadingSections.insert(.mission(id))
        do {
            try await rewardsDM.claimMission(missionId: id)
            if let missions {
                self.missions = missions.map { mission in
                    var mission = mission
                    if mission.id == id {
                        mission.isClaimed = true
                    }
                    return mission
                }
            }
            await pcVM.refresh()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } catch {
            print(error)
        }
        self.loadingSections.remove(.mission(id))
    }
}
