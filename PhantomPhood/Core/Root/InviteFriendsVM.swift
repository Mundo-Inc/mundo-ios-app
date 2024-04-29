//
//  InviteFriendsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/20/24.
//

import Foundation
import Combine
import BranchSDK

@MainActor
final class InviteFriendsVM: ObservableObject {
    private let userProfileDM = UserProfileDM()
    
    private let coreDataManager = UserDataStack.shared
    
    @Published private(set) var referredUsers: [ReferredUserEntity] = []
    @Published private(set) var inviteLinks: [InviteLinkEntity] = []
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var error: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeReferredUserEntity()
        observeInviteLinkEntity()
        
        addRemoveInviteLinks(self.inviteLinks)
        
        Task {
            await fetchReferredUsers()
        }
    }
    
    private func observeReferredUserEntity() {
        let request = ReferredUserEntity.fetchRequest()
        // first sort by confirmedAt and then with createdAt date
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ReferredUserEntity.createdAt, ascending: false)
        ]
        
        ObservableResultPublisher(with: request, context: coreDataManager.viewContext)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in
                    
                },
                receiveValue: { [weak self] items in
                    self?.referredUsers = items
                }
            )
            .store(in: &cancellables)
    }
    
    private func observeInviteLinkEntity() {
        let request = InviteLinkEntity.fetchRequest()
        // first sort by confirmedAt and then with createdAt date
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InviteLinkEntity.createdAt, ascending: true)
        ]
        
        ObservableResultPublisher(with: request, context: coreDataManager.viewContext)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in
                    
                },
                receiveValue: { [weak self] items in
                    self?.inviteLinks = items
                }
            )
            .store(in: &cancellables)
    }
    
    func addRemoveInviteLinks(_ items: [InviteLinkEntity]) {
        var data = items
        // remove expired invites (30 days old)
        data = data.compactMap { invite in
            if let createdAt = invite.createdAt, createdAt.timeIntervalSinceNow < -2592000 {
                self.coreDataManager.viewContext.delete(invite)
                return nil
            }
            return invite
        }
        
        if data.count != items.count {
            Task {
                try? await self.coreDataManager.saveContext()
            }
        }
        
        if UserSettings.shared.inviteCredits < UserSettings.maxInviteCredits {
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
    }
    
    func fetchReferredUsers() async {
        do {
            let resData = try await userProfileDM.getReferredUsers()
        } catch {
            presentErrorToast(error, silent: true)
        }
    }
    
    func generateInviteLink() {
        guard !loadingSections.contains(.inviteLink) else { return }
        
        guard UserSettings.shared.inviteCredits > 0 else {
            self.error = "You don't have any invites left."
            return
        }
        
        if let currentUser = Authentication.shared.currentUser {
            self.loadingSections.insert(.inviteLink)
            HapticManager.shared.impact(style: .light)
            
            let buo: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "signup/\(currentUser.id)")
            buo.title = "Join \(currentUser.name) on Phantom Phood"
            buo.contentDescription = "You've been invited by \(currentUser.name) to Phantom Phood. Join friends in your dining experiences."
            
            if let profileImage = currentUser.profileImage {
                buo.imageUrl = profileImage.absoluteString
            } else {
                buo.imageUrl = "https://phantomphood.ai/img/NoProfileImage.jpg"
            }
            
            let lp: BranchLinkProperties = BranchLinkProperties()
            lp.feature = "referral"
            lp.stage = "ref-\(inviteLinks.count + 1)"
            
            if let topViewController = UIApplication.shared.topViewController() {
                buo.showShareSheet(with: lp, andShareText: "Join \(currentUser.name) on Phantom Phood", from: topViewController) { (activityType, completed, error) in
                    if let error {
                        print(error)
                    } else {
                        self.loadingSections.remove(.inviteLink)
                        if completed {
                            if let url = URL(string: buo.getShortUrl(with: lp) ?? "") {
                                Task {
                                    await self.addInviteLink(url)
                                }
                            }
                        }
                    }
                }
            } else {
                self.loadingSections.remove(.inviteLink)
            }
        }
    }
    
    /// Also changes UserSettings.shared.inviteCredits
    private func addInviteLink(_ link: URL) async {
        let inviteLink = InviteLinkEntity(context: coreDataManager.viewContext)
        inviteLink.link = link
        inviteLink.createdAt = .now
        
        UserSettings.shared.inviteCredits -= 1
        
        try? await coreDataManager.saveContext()
    }
    
    enum LoadingSection: Hashable {
        case inviteLink
    }
}
