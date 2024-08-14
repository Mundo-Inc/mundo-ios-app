//
//  PlaceMediaVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation

class PlaceMediaVM: ObservableObject, LoadingSections {
    private let placeDM = PlaceDM()
    
    private let placeVM: PlaceVM
    
    init(placeVM: PlaceVM) {
        self.placeVM = placeVM
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var mediaItems: [MediaItem] = []
    @Published var initialCall = false
    
    private var mediaPagination: Pagination? = nil
    
    func fetch(type: RefreshNewAction) async {
        guard let placeId = placeVM.place?.id, !loadingSections.contains(.fetchingMedia) else { return }
        
        if type == .refresh {
            mediaPagination = nil
        } else if let mediaPagination, !mediaPagination.hasMore {
            return
        }
        
        setLoadingState(.fetchingMedia, to: true)
        
        defer {
            setLoadingState(.fetchingMedia, to: false)
        }
        
        do {
            let page = if let mediaPagination {
                mediaPagination.page + 1
            } else {
                1
            }
            
            let data = try await placeDM.getMedias(id: placeId, page: page)
            
            await MainActor.run {
                self.initialCall = true
                
                if page == 1 {
                    mediaItems = data.data
                } else {
                    mediaItems.append(contentsOf: data.data)
                }
            }
            
            self.mediaPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
    }
    
    enum LoadingSection: Hashable {
        case fetchingMedia
    }
}
