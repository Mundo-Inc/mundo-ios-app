//
//  HomeActivityInfoVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import Foundation
import Combine

@MainActor
final class HomeActivityInfoVM: ObservableObject {
    static let shared = HomeActivityInfoVM()
    
    private let auth = Authentication.shared
    private let toastVM = ToastVM.shared
    private let connectionsDM = ConnectionsDM()
    
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
                    Task { [weak self] in
                        self?.isLoadingFollowState = true
                        if let followStatus = try? await self?.connectionsDM.followStatus(userId: value.user.id) {
                            DispatchQueue.main.async {
                                if followStatus.followedByUser {
                                    self?.followAction = .unfollow
                                } else if followStatus.followsUser {
                                    self?.followAction = .followBack
                                } else {
                                    self?.followAction = .follow
                                }
                            }
                        }
                        self?.isLoadingFollowState = false
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
            try await connectionsDM.follow(userId: id)
            
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
}
