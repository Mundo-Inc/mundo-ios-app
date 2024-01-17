//
//  ForYouInfoVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import Foundation
import Combine

@MainActor
final class ForYouInfoVM: ObservableObject {
    static let shared = ForYouInfoVM()
    
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    private let toastVM = ToastVM.shared
    
    enum FollowAction: String {
        case follow = "Follow"
        case followBack = "Follow Back"
        case unfollow = "Unfollow"
    }
    
    @Published var data: FeedItem? = nil
    @Published var followAction: FollowAction? = nil
    var handleAddReaction: (EmojisManager.Emoji) -> Void = { _ in }
    
    @Published var isLoadingFollowState = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    var isUserSelf: Bool {
        if let data = self.data {
            if let currentUser = auth.currentUser {
                if data.user.id == currentUser.id {
                    return true
                }
            }
        }
        
        return false
    }
    
    private init() {
        $data
            .sink { value in
                if let value = value {
                    Task {
                        self.isLoadingFollowState = true
                        let followStatus = await self.getFollowStatus(value.user.id)
                        self.isLoadingFollowState = false
                        DispatchQueue.main.async {
                            if let followStatus = followStatus {
                                if followStatus.isFollowing {
                                    self.followAction = .unfollow
                                } else if followStatus.isFollower {
                                    self.followAction = .followBack
                                } else {
                                    self.followAction = .follow
                                }
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func show(_ feedItem: FeedItem, handleAddReaction: @escaping (_ reaction: EmojisManager.Emoji) -> Void) {
        self.data = feedItem
        self.handleAddReaction = handleAddReaction
    }
    
    func reset() {
        self.followAction = nil
        self.handleAddReaction = { _ in }
        self.isLoadingFollowState = false
    }
    
    func follow(id: String) async {
        self.isLoadingFollowState = true
        do {
            guard let token = await auth.getToken() else {
                throw URLError(.userAuthenticationRequired)
            }
            
            try await apiManager.requestNoContent("/users/\(id)/connections", method: .post, token: token)
            
            self.followAction = .unfollow
            
            if let data = self.data {
                toastVM.toast(.init(type: .success, title: "Success", message: "You are now following \(data.user.name)"))
            } else {
                toastVM.toast(.init(type: .success, title: "Success", message: "You are now following this user"))
            }
        } catch {
            toastVM.toast(.init(type: .error, title: "Error", message: "Failed to follow this user"))
            print("DEBUG: Error following user | Error: \(error.localizedDescription)")
        }
        self.isLoadingFollowState = false
    }
    
    struct FollowStatusResponse: Decodable {
        let success: Bool
        let data: FollowStatus
        
        struct FollowStatus: Decodable {
            let isFollowing: Bool
            let isFollower: Bool
        }
    }
    private func getFollowStatus(_ userId: String) async -> FollowStatusResponse.FollowStatus? {
        guard let token = await auth.getToken() else { return nil }
        
        do {
            let data = try await apiManager.requestData("/users/\(userId)/connections/followStatus", method: .get, token: token) as FollowStatusResponse?
            
            if let data {
                return data.data
            }
        } catch {
            print("DEBUG: Couldn't get user followStatus | Error: \(error.localizedDescription)")
        }
        
        return nil
    }
}
