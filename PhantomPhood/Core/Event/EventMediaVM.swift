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
    @Published var mediaItems: [MediaWithUser]? = nil
    
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
                mediaItems = data
            } else if mediaItems != nil {
                mediaItems!.append(contentsOf: data)
            } else {
                mediaItems = data
            }
            page += 1
        } catch {
            presentErrorToast(error)
        }
        isLoading = false
    }
}
