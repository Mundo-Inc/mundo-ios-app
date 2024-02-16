//
//  RewardsHubVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI
import CoreData
import BranchSDK

@MainActor
final class RewardsHubVM: ObservableObject {
    private let auth = Authentication.shared
    private let pcVM = PhantomCoinsVM.shared
    private let rewardsDM = RewardsDM()
    
    init() {
        getUserInvites()
        Task {
            await getPrizes()
        }
    }
    
    enum LoadingSection: Hashable {
        case inviteLink
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
    
    @Published var userInviteLinks: [InviteLinkEntity]? = nil
    
    var unconfirmedUserInvites: [InviteLinkEntity] {
        if let invites = self.userInviteLinks {
            return invites.filter { $0.referredUser == nil }
        } else {
            return []
        }
    }
    
    func claimDailyReward() async {
        guard !pcVM.hasClaimedToday && !loadingSections.contains(.dailyReward) else { return }
        
        self.loadingSections.insert(.dailyReward)
        do {
            try await rewardsDM.claimDailyRewards()
            await pcVM.refresh()
            HapticManager.shared.notification(type: .success)
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
    
    func getPrizes() async {
        guard !loadingSections.contains(.prizes) else { return }
        
        self.loadingSections.insert(.prizes)
        do {
            let data = try await rewardsDM.getPrizes()
            self.prizes = data
        } catch {
            print(error)
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
            print(error)
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
            print(error)
        }
        self.loadingSections.remove(.mission(id))
    }
    
    func getInviteLink() {
        guard !loadingSections.contains(.inviteLink) else { return }
        
        guard UserSettings.shared.inviteCredits > 0 else {
            self.error = "You don't have any invites left."
            return
        }
        
        if let currentUser = auth.currentUser {
            self.loadingSections.insert(.inviteLink)
            HapticManager.shared.impact(style: .light)
            
            let buo: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "signup/\(currentUser.id)")
            buo.title = "Join \(currentUser.name) on Phantom Phood"
            buo.contentDescription = "You've been invited by \(currentUser.name) to Phantom Phood. Join friends in your dining experiences."
            
            if !currentUser.profileImage.isEmpty {
                buo.imageUrl = currentUser.profileImage
            } else {
                buo.imageUrl = "https://phantomphood.ai/img/NoProfileImage.jpg"
            }
            
            let lp: BranchLinkProperties = BranchLinkProperties()
            lp.feature = "referral"
            lp.stage = "ref-\((userInviteLinks?.count ?? 0) + 1)"
            
            if let topViewController = UIApplication.shared.topViewController() {
                buo.showShareSheet(with: lp, andShareText: "Join \(currentUser.name) on Phantom Phood", from: topViewController) { (activityType, completed, error) in
                    if let error {
                        print(error)
                    } else {
                        self.loadingSections.remove(.inviteLink)
                        if completed {
                            if let url = URL(string: buo.getShortUrl(with: lp) ?? "") {
                                self.addInviteLink(url)
                            }
                        }
                    }
                }
            } else {
                self.loadingSections.remove(.inviteLink)
            }
        }
    }
    
    // MARK: - Core Data
    
    func getUserInvites() {
        let request = NSFetchRequest<InviteLinkEntity>(entityName: "InviteLinkEntity")
        // first sort by confirmedAt and then with createdAt date
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InviteLinkEntity.confirmedAt, ascending: true),
            NSSortDescriptor(keyPath: \InviteLinkEntity.createdAt, ascending: true)
        ]
        
        do {
            var data = try CoreDataStack.shared.viewContext.fetch(request)
            
            // remove expired invites (30 days old)
            data = data.compactMap { invite in
                if let confirmedAt = invite.confirmedAt, confirmedAt.timeIntervalSinceNow < -2592000 {
                    CoreDataStack.shared.viewContext.delete(invite)
                    return nil
                }
                return invite
            }
            
            let uncomfirmed = data.filter { $0.referredUser == nil }
            
            if uncomfirmed.count + UserSettings.shared.inviteCredits < UserSettings.maxInviteCredits {
                if UserSettings.shared.inviteCredits == 0, UserSettings.shared.inviteCreditsLastGiven.timeIntervalSinceNow < -172800 {
                    // 2 days for next credit
                    UserSettings.shared.inviteCredits += 1
                    UserSettings.shared.inviteCreditsLastGiven = .now
                } else if UserSettings.shared.inviteCreditsLastGiven.timeIntervalSinceNow < -604800 {
                    // 7 days for next credit
                    UserSettings.shared.inviteCredits += 1
                    UserSettings.shared.inviteCreditsLastGiven = .now
                }
            }
            
            self.userInviteLinks = data
        } catch {
            print(error)
        }
    }
    
    func addInviteLink(_ link: URL) {
        let context = CoreDataStack.shared.viewContext
        let inviteLink = InviteLinkEntity(context: context)
        inviteLink.link = link
        inviteLink.createdAt = .now
        
        UserSettings.shared.inviteCredits -= 1
        
        saveCoreData()
    }
    
    private func saveCoreData() {
        do {
            try CoreDataStack.shared.saveContext()
            getUserInvites()
        } catch {
            print(error)
        }
    }
}
