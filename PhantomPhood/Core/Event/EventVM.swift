//
//  EventVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

final class EventVM: ObservableObject, LoadingSections {
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
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var event: Event? = nil
    
    @Published var expandedMedia: MediaItem? = nil
    
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
        
        setLoadingState(.getEvent, to: true)
        
        defer {
            setLoadingState(.getEvent, to: false)
        }
        
        do {
            let data = try await eventsDM.getEvent(self.eventId)
            
            await MainActor.run {
                self.event = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    enum Sheets {
        case navigationOptions
    }
    
    enum EventTab: String, CaseIterable, Hashable {
        case media = "Media"
        case checkIns = "Check Ins"
    }
}
