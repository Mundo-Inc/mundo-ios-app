//
//  MapActivitySheetVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/29/24.
//

import Foundation

final class MapActivitySheetVM: ObservableObject {
    private let userActivityDM = UserActivityDM()
    private let conversationsDM = ConversationsDM()
    
    enum LoadingSection: Hashable {
        case startingConversation
    }
    
    @Published private(set) var loadingSections = Set<LoadingSection>()
    
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
        DispatchQueue.main.async {
            self.loadingSections.insert(.startingConversation)
        }
        do {
            let conversation = try await conversationsDM.createConversation(with: userId)
            
            HapticManager.shared.impact(style: .light)
            
            AppData.shared.goTo(.conversation(sid: conversation.sid, focusOnTextField: true))
        } catch {
            presentErrorToast(error)
            HapticManager.shared.notification(type: .error)
        }
        
        DispatchQueue.main.async {
            self.loadingSections.remove(.startingConversation)
        }
    }
}
