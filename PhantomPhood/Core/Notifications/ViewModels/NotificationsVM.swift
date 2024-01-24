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
    
    private let dataManager = NotificationsDM()
    
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int? = nil
    @Published var isLoading: Bool = false
    @Published var hasMore: Bool = true
    
    var page: Int = 1
    
    enum GetNotificationAction {
        case refresh
        case new
    }
    
    func getNotifications(_ action: GetNotificationAction) async {
        if action == .refresh {
            page = 1
        }
        
        if isLoading {
            return
        }
        do {
            self.isLoading = true
            let data = try await dataManager.getNotifications(page: self.page)
            
            hasMore = data.hasMore
            
            if action == .refresh || self.notifications.isEmpty {
                self.notifications = data.data.notifications
            } else {
                self.notifications.append(contentsOf: data.data.notifications)
            }
            
            self.isLoading = false
            page += 1
        } catch {
            print(error)
        }
    }
    
    func loadMore(currentItem item: Notification) async {
        let thresholdIndex = notifications.index(notifications.endIndex, offsetBy: -5)
        if notifications.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            await getNotifications(.new)
        }
    }
    
    func updateUnreadNotificationsCount() async {
        do {
            let data = try await dataManager.getNotifications(page: self.page, unread: true)
            
            self.unreadCount = data.data.total
            try? await UNUserNotificationCenter.current().setBadgeCount(data.data.total)
        } catch {
            print(error)
        }
    }
    
    func seenNotifications() async {
        do {
            try await dataManager.markNotificationsAsRead()
            
            self.notifications = self.notifications.map({ notification in
                var new = notification
                new.readAt = DateFormatter.dateToString(date: Date())
                return new
            })
            await updateUnreadNotificationsCount()
        } catch {
            print(error)
        }
    }
}
