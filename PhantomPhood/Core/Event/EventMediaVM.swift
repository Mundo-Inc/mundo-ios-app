//
//  EventMediaVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import Foundation

@MainActor
final class EventMediaVM: ObservableObject {
    private let mediaDM = MediaDM()
    
    private let eventVM: EventVM
    
    init(eventVM: EventVM) {
        self.eventVM = eventVM
    }
    
    @Published var isLoading: Bool = false
    @Published var medias: [MediaWithUser]? = nil
    
    var page = 1
    func fetch(type: RefreshNewAction) async {
        guard let eventId = eventVM.event?.id, !isLoading else { return }

        if type == .refresh {
            page = 1
        }
        
        isLoading = true
        do {
            let data = try await mediaDM.getMedia(event: eventId, page: page)
            if page == 1 {
                medias = data
            } else if medias != nil {
                medias!.append(contentsOf: data)
            } else {
                medias = data
            }
            page += 1
        } catch {
            presentErrorToast(error)
        }
        isLoading = false
    }
}
