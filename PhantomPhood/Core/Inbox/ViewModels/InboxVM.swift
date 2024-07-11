//
//  InboxVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import Foundation

@MainActor
final class InboxVM: ObservableObject {
    private let userProfileDM = UserProfileDM()
    
    @Published var activeTab: Tab = .notifications
    @Published var usersDict: [String:UserEssentials] = [:]
    
    func getUsers(ids: [String]) async {
        do {
            let users = try await userProfileDM.getUserEssentialsAndUpdate(ids: Set(ids), updateAll: false, coreDataCompletion: { [weak self] users in
                DispatchQueue.main.async {
                    for user in users {
                        self?.usersDict.updateValue(user, forKey: user.id)
                    }
                }
            })
            
            DispatchQueue.main.async {
                for user in users {
                    self.usersDict.updateValue(user, forKey: user.id)
                }
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: Enums
    
    enum Tab: String {
        case messages = "Messages"
        case notifications = "Notifications"
    }
}
