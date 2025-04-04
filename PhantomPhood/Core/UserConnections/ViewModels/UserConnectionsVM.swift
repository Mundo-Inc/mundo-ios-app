//
//  UserConnectionsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/1/23.
//

import Foundation

@MainActor
class UserConnectionsVM: ObservableObject {
    private let connectionsDM = ConnectionsDM()
    
    @Published var isLoading: Bool = false
    
    @Published var followers: [UserConnection]? = nil
    @Published var followings: [UserConnection]? = nil
    
    private var followersPage = 1
    private var followingsPage = 1
    private var totalFollowings: Int? = nil
    private var totalFollowers: Int? = nil
    
    private let DATA_LIMIT: Int = 30
    
    enum RequestType {
        case refresh
        case new
    }
    
    func getConnections(userId: String, type: ConnectionsDM.UserConnectionType, requestType: RequestType) async {
        if isLoading { return }
        
        isLoading = true

        if requestType == .refresh {
            switch type {
            case .followers:
                followersPage = 1
            case .followings:
                followingsPage = 1
            }
        } else {
            switch type {
            case .followings:
                if let totalFollowings {
                    if followings?.count ?? 0 >= totalFollowings {
                        isLoading = false
                        return
                    }
                }
            case .followers:
                if let totalFollowers {
                    if followers?.count ?? 0 >= totalFollowers {
                        isLoading = false
                        return
                    }
                }
            }
        }
        
        do {
            let connections = try await connectionsDM.getConnections(userId: userId, type: type, page: type == .followers ? followersPage : followingsPage, limit: DATA_LIMIT)
            
            switch type {
            case .followers:
                self.followersPage += 1
                self.totalFollowers = connections.pagination.totalCount
                if self.followers != nil && requestType == .new {
                    self.followers!.append(contentsOf: connections.data)
                } else {
                    self.followers = connections.data
                }
            case .followings:
                self.followingsPage += 1
                self.totalFollowings = connections.pagination.totalCount
                if self.followings != nil && requestType == .new {
                    self.followings!.append(contentsOf: connections.data)
                } else {
                    self.followings = connections.data
                }
            }
        } catch {
            presentErrorToast(error)
        }
        
        isLoading = false
    }
    
    func loadMore(userId: String, type: ConnectionsDM.UserConnectionType, currentItem: UserConnection) async {
        var thresholdIndex: Int
        switch type {
        case .followings:
            if let followings {
                thresholdIndex = followings.index(followings.endIndex, offsetBy: -5)
                if followings.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
                    await getConnections(userId: userId, type: .followings, requestType: .new)
                }
            } else {
                return
            }
        case .followers:
            if let followers {
                thresholdIndex = followers.index(followers.endIndex, offsetBy: -5)
                if followers.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
                    await getConnections(userId: userId, type: .followers, requestType: .new)
                }
            } else {
                return
            }
        }
    }

}
