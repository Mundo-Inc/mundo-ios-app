//
//  UserProfileViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    private let id: String
    
    private let dataManager = UserProfileDataManager()
    private let toastManager = ToastViewModel.shared
    
    @Published private(set) var isLoading = false
    @Published private(set) var isFollowing: Bool? = nil
    @Published private(set) var user: UserProfile?
    @Published private(set) var error: String?
    
    init(id: String) {
        self.id = id
        
        Task {
            await fetchUser()
        }
    }
    
    func fetchUser() async {
        do {
            let theUser = try await dataManager.fetch(id: id)
            self.user = theUser
            self.isFollowing = theUser.isFollowing
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func follow() async {
        do {
            try await dataManager.follow(id: id)
            self.isFollowing = true
            if let user {
                toastManager.toast(Toast(type: .success, title: "New Connection", message: "You are now following \(user.name)"))
            }
        } catch {
            if let user {
                toastManager.toast(Toast(type: .error, title: "Failed", message: "Failed to follow \(user.name)"))
            }
        }
    }
    
    func unfollow() async {
        do {
            try await dataManager.unfollow(id: id)
            self.isFollowing = false
            if let user {
                toastManager.toast(Toast(type: .success, title: "Unfollow", message: "Successfully unfollowed \(user.name)"))
            }
        } catch {
            if let user {
                toastManager.toast(Toast(type: .error, title: "Failed", message: "Failed to unfollow \(user.name)"))
            }
        }
    }

}
