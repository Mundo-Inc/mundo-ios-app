//
//  MyConnectionsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/31/23.
//

import Foundation

class MyConnectionsVM: LoadingSections, ObservableObject {
    private let connectionsDM = ConnectionsDM()
    private let userProfileDM = UserProfileDM()
    
    private let auth = Authentication.shared
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var followers: [UserConnection]? = nil
    @Published var followings: [UserConnection]? = nil
    
    private var followersPagination: Pagination?
    private var followingsPagination: Pagination?
    
    private let DATA_LIMIT: Int = 30
    
    func getFollowers(_ requestType: RefreshNewAction) async {
        guard let userId = auth.currentUser?.id, !loadingSections.contains(.fetchingFollowers) else { return }
        
        if requestType == .refresh {
            followersPagination = nil
        } else if let followersPagination, !followersPagination.hasMore {
            return
        }
        
        setLoadingState(.fetchingFollowers, to: true)
        do {
            let page = (followersPagination?.page ?? 0) + 1
            
            let result = try await connectionsDM.getConnections(userId: userId, type: .followers, page: page, limit: DATA_LIMIT)
            
            followersPagination = result.pagination
            
            await MainActor.run {
                if self.followers != nil && requestType == .new {
                    self.followers!.append(contentsOf: result.data)
                } else {
                    self.followers = result.data
                }
            }
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.fetchingFollowers, to: false)
    }
    
    func getFollowings(_ requestType: RefreshNewAction) async {
        guard let userId = auth.currentUser?.id, !loadingSections.contains(.fetchingFollowings) else { return }
        
        if requestType == .refresh {
            followingsPagination = nil
        } else if let followingsPagination, !followingsPagination.hasMore {
            return
        }
        
        setLoadingState(.fetchingFollowers, to: true)
        do {
            let page = (followingsPagination?.page ?? 0) + 1
            
            let result = try await connectionsDM.getConnections(userId: userId, type: .followings, page: page, limit: DATA_LIMIT)
            
            followingsPagination = result.pagination
            
            await MainActor.run {
                if self.followings != nil && requestType == .new {
                    self.followings!.append(contentsOf: result.data)
                } else {
                    self.followings = result.data
                }
            }
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.fetchingFollowers, to: false)
    }
    
    func loadMore(type: ConnectionsDM.UserConnectionType, currentItem: UserConnection) async {
        switch type {
        case .followings:
            guard let followings, !loadingSections.contains(.fetchingFollowings) else { return }
            let thresholdIndex = followings.index(followings.endIndex, offsetBy: -5)
            if followings.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
                await getFollowings(.new)
            }
        case .followers:
            guard let followers, !loadingSections.contains(.fetchingFollowers) else { return }
            let thresholdIndex = followers.index(followers.endIndex, offsetBy: -5)
            if followers.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
                await getFollowers(.new)
            }
        }
    }
    
    func removeFollower(userId: String) async {
        guard !loadingSections.contains(.removingFollower(userId)) else { return }
        
        setLoadingState(.removingFollower(userId), to: true)
        do {
            try await userProfileDM.removeFollower(id: userId)
            await MainActor.run {
                self.followers = self.followers?.filter({ $0.user.id != userId })
            }
            HapticManager.shared.notification(type: .success)
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.removingFollower(userId), to: false)
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case fetchingFollowers
        case fetchingFollowings
        case removingFollower(String)
    }
}
