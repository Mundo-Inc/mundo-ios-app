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
    
    @Published var activeTab: Tab = .messages
    @Published var usersDict: [String:UserEssentials] = [:]
    
    func getUser(id: String) async {
        do {
            if let user = try await userProfileDM.getUserEssentialsAndUpdate(id: id, returnIfFound: true, coreDataCompletion: { [weak self] user in
                DispatchQueue.main.async {
                    self?.usersDict.updateValue(user, forKey: user.id)
                }
            }) {
                self.usersDict.updateValue(user, forKey: user.id)
            }
        } catch {
            presentErrorToast(error, debug: "Error fetching user info \(id)")
        }
    }
    
    // MARK: Enums
    
    enum Tab: String {
        case messages = "Messages"
        case notifications = "Notifications"
    }
}
