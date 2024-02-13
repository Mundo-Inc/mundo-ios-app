//
//  RewardsHubVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI
import BranchSDK

@MainActor
final class RewardsHubVM: ObservableObject {
    private let auth = Authentication.shared
    private let pcVM = PhantomCoinsVM.shared
    private let rewardsDM = RewardsDM()
    
    enum LoadingSection: Hashable {
        case inviteLink
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
    
    func getInviteLink() {
        guard !loadingSections.contains(.inviteLink) else { return }
        
        if let currentUser = auth.currentUser {
            self.loadingSections.insert(.inviteLink)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            let buo: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "signup/\(currentUser.id)")
            buo.title = "Join \(currentUser.name) in Phantom Phood"
            buo.contentDescription = "You've been invited by \(currentUser.name) to Phantom Phood. Join friends in your dining experiences."
            
            if !currentUser.profileImage.isEmpty {
                buo.imageUrl = currentUser.profileImage
            } else {
                buo.imageUrl = "https://phantomphood.ai/img/NoProfileImage.jpg"
            }
            
            let lp: BranchLinkProperties = BranchLinkProperties()
            lp.feature = "referral"
            lp.stage = "ref-\(UserSettings.shared.referralsGenerated + 1)"
            
            if let topViewController = UIApplication.shared.topViewController() {
                buo.showShareSheet(with: lp, andShareText: "Join \(currentUser.name) in Phantom Phood", from: topViewController) { (activityType, completed) in
                    self.loadingSections.remove(.inviteLink)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if completed {
                        UserSettings.shared.referralsGenerated += 1
                    }
                }
            } else {
                self.loadingSections.remove(.inviteLink)
            }
        }
    }
}
