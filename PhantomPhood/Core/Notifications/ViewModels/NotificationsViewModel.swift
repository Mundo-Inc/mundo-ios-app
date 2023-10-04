//
//  NotificationsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class NotificationsViewModel: ObservableObject {
    private let dataManager = NotificationsDataManager()
    
    @Published var notifications: [Notification] = []
    @Published var isLoading: Bool = false
    @Published var hasMore: Bool = true
    
    var page: Int = 1
    
    init() {
        Task {
            await getNotifications(.refresh)
        }
    }
    
    
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
}
