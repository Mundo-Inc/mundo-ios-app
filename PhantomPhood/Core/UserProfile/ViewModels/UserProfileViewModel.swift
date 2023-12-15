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
    
    private let dataManager = UserProfileDM()
    private let toastManager = ToastViewModel.shared
    
    @Published private(set) var isLoading = false
    @Published private(set) var isFollowing: Bool? = nil
    @Published private(set) var user: UserProfile?
    @Published private(set) var error: String?
    
    @Published var showActions = false
    @Published var blockStatus: BlockStatus? = nil
    
    enum BlockStatus {
        case isBlocked
        case hasBlocked
    }
    
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
            guard let theError = error as? APIManager.APIError else { return }
            switch theError {
            case .serverError(let serverError):
                if serverError.statusCode == 403 {
                    if serverError.message == "You have blocked this user" {
                        self.blockStatus = .isBlocked
                    } else {
                        self.blockStatus = .hasBlocked
                    }
                    self.user = nil
                    self.isLoading = false
                    self.isFollowing = nil
                }
                self.error = serverError.message
            case .decodingError(let decodingError):
                self.error = decodingError.localizedDescription
            case .unknown:
                print("Unknown error")
            }
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
    
    func block() async {
        self.isLoading = true
        do {
            try await dataManager.block(id: id)
            self.user = nil
            self.isFollowing = nil
            self.blockStatus = .isBlocked
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
    func unblock() async {
        self.isLoading = true
        do {
            try await dataManager.unblock(id: id)
            self.blockStatus = nil
            await fetchUser()
        } catch {
            print(error)
        }
        self.isLoading = false
    }
}
