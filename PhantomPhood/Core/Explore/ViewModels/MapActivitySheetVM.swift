//
//  MapActivitySheetVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/29/24.
//

import Foundation

final class MapActivitySheetVM: ObservableObject, LoadingSections {
    private let userActivityDM = UserActivityDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
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
            presentErrorToast(error)
        }
    }
    
    func startConversation(with userId: String) async {
        ToastVM.shared.toast(Toast(type: .info, title: "Messaging is disabled", message: "We're improving messaging system and it's temporarily disabled"))
    }
}

extension MapActivitySheetVM {
    enum LoadingSection: Hashable {
        case startingConversation
    }
}
