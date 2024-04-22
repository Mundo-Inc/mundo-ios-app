//
//  RewardsHubVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
final class RewardsHubVM: ObservableObject {
    private let pcVM = PhantomCoinsVM.shared
    private let rewardsDM = RewardsDM()
    
    init() {
        Task {
            await getPrizes()
        }
    }
    
    enum LoadingSection: Hashable {
        case dailyReward
        case missions
        case mission(String)
        case prizes
        case redeeming
    }
    
    @Published var error: String? = nil
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var missions: [Mission]? = nil
    @Published var prizes: [Prize]? = nil
    @Published var selectedPrize: Prize? = nil
    
    func claimDailyReward() async {
        guard !pcVM.hasClaimedToday && !loadingSections.contains(.dailyReward) else { return }
        
        self.loadingSections.insert(.dailyReward)
        do {
            try await rewardsDM.claimDailyRewards()
            await pcVM.refresh()
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
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
            presentErrorToast(error)
        }
        self.loadingSections.remove(.missions)
    }
    
    func getPrizes() async {
        guard !loadingSections.contains(.prizes) else { return }
        
        self.loadingSections.insert(.prizes)
        do {
            let data = try await rewardsDM.getPrizes()
            self.prizes = data
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.prizes)
    }
    
    func redeemPrize(id: String) async {
        guard !loadingSections.contains(.redeeming) else { return }
        
        HapticManager.shared.impact(style: .light)
        self.loadingSections.insert(.redeeming)
        do {
            try await rewardsDM.redeemPrize(id: id)
            await pcVM.refresh()
            withAnimation {
                self.selectedPrize = nil
            }
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.redeeming)
    }
    
    func claimMissions(id: String) async {
        guard !loadingSections.contains(.missions) && !loadingSections.contains(.mission(id)) else { return }
        
        HapticManager.shared.impact(style: .light)
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
        } catch {
            presentErrorToast(error)
        }
        self.loadingSections.remove(.mission(id))
    }
}
