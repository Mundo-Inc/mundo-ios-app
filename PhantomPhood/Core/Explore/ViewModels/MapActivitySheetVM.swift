//
//  MapActivitySheetVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/29/24.
//

import Foundation

final class MapActivitySheetVM: ObservableObject {
    let userActivityDM = UserActivityDM()
    
    @Published var show = false
    @Published var selection: Int = 0
    
    @Published var feedItems: [String: FeedItem] = [:]
    
    func showActivity(activity: MapActivity) async {
        guard feedItems[activity.id] == nil else { return }
        
        do {
            let data = try await userActivityDM.getUserActivity(activity.id)
            DispatchQueue.main.async {
                self.feedItems[activity.id] = data
            }
        } catch {
            print("Failed to fetch")
        }
    }
}
