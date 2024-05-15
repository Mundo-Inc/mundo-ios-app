//
//  NotificationsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation
import SwiftUI

final class NotificationsVM: LoadingSections, ObservableObject {
    static let shared = NotificationsVM()
    
    private init() {}
    
    private let notificationsDM = NotificationsDM()
    private let userProfileDM = UserProfileDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published private(set) var notificationsCluster: [NotificationsUserCluster] = []
    @Published private(set) var unreadCount: Int? = nil
    
    @Published private(set) var followRequests: [FollowRequest] = []
    @Published private(set) var followRequestsCount: Int? = nil
    
    private var notificationsPagination: Pagination? = nil
    private var followRequestsPagination: Pagination? = nil
    
    func getNotifications(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.fetchingNotifications) else { return }

        if action == .refresh {
            notificationsPagination = nil
        } else if let notificationsPagination {
            if notificationsPagination.page * notificationsPagination.limit >= notificationsPagination.totalCount {
                return
            }
        }

        setLoadingState(.fetchingNotifications, to: true)
        do {
            let page: Int
            if let notificationsPagination {
                page = notificationsPagination.page + 1
            } else {
                page = 1
            }
            
            let data = try await notificationsDM.getNotifications(page: page)
            
            await MainActor.run {
                if action == .refresh || self.notificationsCluster.isEmpty {
                    self.notificationsCluster = getNotificationClusterByUser(data.data)
                } else {
                    self.notificationsCluster.append(contentsOf: getNotificationClusterByUser(data.data))
                }
            }
            
            notificationsPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.fetchingNotifications, to: false)
    }
    
    func getFollowRequests(_ action: RefreshNewAction) async {
        guard !loadingSections.contains(.fetchingFollowRequests) else { return }

        if action == .refresh {
            followRequestsPagination = nil
        } else if let followRequestsPagination {
            if followRequestsPagination.page * followRequestsPagination.limit >= followRequestsPagination.totalCount {
                return
            }
        }

        setLoadingState(.fetchingFollowRequests, to: true)
        do {
            let page: Int
            if let followRequestsPagination {
                page = followRequestsPagination.page + 1
            } else {
                page = 1
            }
            
            let data = try await userProfileDM.getFollowRequests(page: page)
            
            await MainActor.run {
                if action == .refresh || self.notificationsCluster.isEmpty {
                    self.followRequests = data.data
                } else {
                    self.followRequests.append(contentsOf: data.data)
                }
                followRequestsCount = data.pagination.totalCount
            }
            
            followRequestsPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.fetchingFollowRequests, to: false)
    }
    
    func acceptRequest(for requestId: String) async {
        guard !loadingSections.contains(.acceptingRequest(requestId)) else { return }
        
        setLoadingState(.acceptingRequest(requestId), to: true)
        do {
            try await userProfileDM.acceptRequest(for: requestId)
            await MainActor.run {
                followRequests = followRequests.map({ req in
                    if req.id == requestId {
                        var newReq = req
                        newReq.user.setConnectionStatus(followedBy: .following)
                        return newReq
                    } else {
                        return req
                    }
                })
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.acceptingRequest(requestId), to: false)
    }
    
    func rejectRequest(for requestId: String) async {
        guard !loadingSections.contains(.rejectingRequest(requestId)) else { return }
        
        setLoadingState(.rejectingRequest(requestId), to: true)
        do {
            try await userProfileDM.rejectRequest(for: requestId)
            await MainActor.run {
                followRequests = followRequests.map({ req in
                    if req.id == requestId {
                        var newReq = req
                        newReq.user.setConnectionStatus(followedBy: .notFollowing)
                        return newReq
                    } else {
                        return req
                    }
                })
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.rejectingRequest(requestId), to: false)
    }
    
    func follow(user userId: String) async {
        guard !loadingSections.contains(.followRequest(userId)) else { return }
        
        setLoadingState(.followRequest(userId), to: true)
        do {
            let status = try await userProfileDM.follow(id: userId)
            
            await MainActor.run {
                followRequests = followRequests.map({ req in
                    if req.user.id == userId {
                        var newReq = req
                        switch status {
                        case .following:
                            newReq.user.setConnectionStatus(following: .following)
                        case .requested:
                            newReq.user.setConnectionStatus(following: .requested)
                        }
                        return newReq
                    } else {
                        return req
                    }
                })
            }
        } catch {
            presentErrorToast(error, function: #function)
        }
        setLoadingState(.followRequest(userId), to: false)
    }
    
    func loadMore(index: Int) async {
        let thresholdIndex = notificationsCluster.index(notificationsCluster.endIndex, offsetBy: -5)
        if index >= thresholdIndex {
            await getNotifications(.new)
        }
    }
    
    func updateUnreadNotificationsCount() async {
        do {
            let data = try await notificationsDM.getNotifications(page: 1, unread: true)
            
            await MainActor.run {
                self.unreadCount = data.pagination.totalCount
            }
            try? await UNUserNotificationCenter.current().setBadgeCount(data.pagination.totalCount)
        } catch {
            presentErrorToast(error)
        }
    }
    
    func seenNotifications() async {
        do {
            try await notificationsDM.markNotificationsAsRead()
            
            let now = Date.now
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.notificationsCluster = self.notificationsCluster.map({ cluster in
                    var new = cluster
                    new.items = new.items.map({ notification in
                        if notification.readAt == nil {
                            var n = notification
                            n.readAt = now
                            return n
                        } else {
                            return notification
                        }
                    })
                    return new
                })
            }
            
            await updateUnreadNotificationsCount()
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: Private methods
    
    private func getNotificationClusterByUser(_ notifications: [Notification]) -> [NotificationsUserCluster] {
        var items: [NotificationsUserCluster] = []
        
        for notification in notifications {
            let lastIndex = items.count - 1
            if lastIndex >= 0 {
                if notification.user == items[lastIndex].user {
                    items[lastIndex].add(notification)
                } else {
                    items.append(NotificationsUserCluster(user: notification.user, items: [notification]))
                }
            } else {
                items.append(NotificationsUserCluster(user: notification.user, items: [notification]))
            }
        }
        
        return items
    }
    
    // MARK: Structs
    
    struct NotificationsUserCluster {
        let user: UserEssentials?
        var items: [Notification]
        
        mutating func add(_ item: Notification) {
            self.items.append(item)
        }
    }
    
    enum LoadingSection: Hashable {
        case fetchingNotifications
        case fetchingFollowRequests
        case rejectingRequest(String)
        case acceptingRequest(String)
        case followRequest(String)
    }
}
