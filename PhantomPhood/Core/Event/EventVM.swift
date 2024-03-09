//
//  EventVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

@MainActor
final class EventVM: ObservableObject {
    private let toastVM = ToastVM.shared
    private let eventsDM = EventsDM()
    
    enum LoadingSection: Hashable {
        case getEvent
    }
    
    private let eventId: String
    
    private var mediaPage = 1
    private var checkInPage = 1
    
    @Published var activeTab: EventTab = .media
    @Published var presentedSheet: Sheets? = nil
    @Published private(set) var loadingSections = Set<LoadingSection>()
    
    @Published var event: Event? = nil
    
    @Published var expandedMedia: MediaWithUser? = nil
    
    @Published var draggedAmount: CGSize = .zero
    
    init(event: Event) {
        self.eventId = event.id
        self.event = event
    }
    
    init(id: String) {
        self.eventId = id
        Task {
            await getEvent()
        }
    }
    
    func getEvent() async {
        guard !loadingSections.contains(.getEvent) else { return }
        
        loadingSections.insert(.getEvent)
        do {
            let data = try await eventsDM.getEvent(self.eventId)
            self.event = data
        } catch {
            toastVM.toast(.init(type: .error, title: "Something went wrong", message: "Couldn't fetch event info"))
        }
        loadingSections.remove(.getEvent)
    }
    
    func getMedia() async {
        
    }
    
    func getCheckIn() async {
        
    }
    
    enum Sheets {
        case navigationOptions
    }
    
    enum EventTab: String, CaseIterable, Hashable {
        case media = "Media"
        case checkIns = "Check Ins"
    }
}
