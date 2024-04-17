//
//  NotificationsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation
import SwiftUI

@MainActor
final class NotificationsVM: ObservableObject {
    static let shared = NotificationsVM()
    
    private init() {}
    
    private let notificationsDM = NotificationsDM()
    
    @Published var notificationsCluster: [NotificationsUserCluster] = []
    @Published var unreadCount: Int? = nil
    @Published var isLoading: Bool = false
    @Published var hasMore: Bool = true
    
    private var page: Int = 1
    
    func getNotifications(_ action: RefreshNewAction) async {
        guard !isLoading else { return }

        if action == .refresh {
            page = 1
        }

        self.isLoading = true
        do {
            let data = try await notificationsDM.getNotifications(page: self.page)
            
            hasMore = data.pagination.totalCount > data.pagination.page * data.pagination.limit
            
            if action == .refresh || self.notificationsCluster.isEmpty {
                self.notificationsCluster = getNotificationClusterByUser(data.data)
            } else {
                self.notificationsCluster.append(contentsOf: getNotificationClusterByUser(data.data))
            }
            
            page += 1
        } catch {
            presentErrorToast(error)
        }
        self.isLoading = false
    }
    
    func loadMore(index: Int) async {
        let thresholdIndex = notificationsCluster.index(notificationsCluster.endIndex, offsetBy: -5)
        if index == thresholdIndex {
            await getNotifications(.new)
        }
    }
    
    func updateUnreadNotificationsCount() async {
        do {
            let data = try await notificationsDM.getNotifications(page: self.page, unread: true)
            
            self.unreadCount = data.pagination.totalCount
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
}
