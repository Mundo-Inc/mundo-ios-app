//
//  EventMediaVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import Foundation

final class EventMediaVM: ObservableObject, LoadingSections {
    private let mediaDM = MediaDM()
    
    private let eventVM: EventVM
    
    init(eventVM: EventVM) {
        self.eventVM = eventVM
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published private(set) var mediaItems: [MediaItem]? = nil
    
    private var pagination: Pagination? = nil
    
    func fetch(type: RefreshNewAction) async {
        guard let eventId = eventVM.event?.id, !loadingSections.contains(.fetchMedia) else { return }

        if type == .refresh {
            pagination = nil
        } else if let pagination, !pagination.hasMore {
            return
        }
        
        setLoadingState(.fetchMedia, to: true)
        
        defer {
            setLoadingState(.fetchMedia, to: false)
        }
        
        do {
            let page = (pagination?.page ?? 0) + 1
            
            let data = try await mediaDM.getMedia(event: eventId, page: page)
            
            await MainActor.run {
                if page == 1 {
                    mediaItems = data.data
                } else if mediaItems != nil {
                    mediaItems!.append(contentsOf: data.data)
                } else {
                    mediaItems = data.data
                }
            }
            
            pagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
    }
    
    enum LoadingSection: Hashable {
        case fetchMedia
    }
}
