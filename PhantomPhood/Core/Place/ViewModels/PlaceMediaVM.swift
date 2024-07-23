//
//  PlaceMediaVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation

@MainActor
class PlaceMediaVM: ObservableObject {
    private let placeDM = PlaceDM()
    
    private let placeVM: PlaceVM
    
    init(placeVM: PlaceVM) {
        self.placeVM = placeVM
    }
    
    @Published var isLoading: Bool = false
    @Published var mediaItems: [MediaWithUser] = []
    @Published var initialCall = false
    
    var page = 1
    func fetch(type: FetchType) async {
        guard let placeId = placeVM.place?.id, !isLoading else { return }

        if type == .refresh {
            page = 1
        }
        
        isLoading = true
        do {
            let data = try await placeDM.getMedias(id: placeId, page: page)
            self.initialCall = true
            if page == 1 {
                mediaItems = data.data
            } else {
                mediaItems.append(contentsOf: data.data)
            }
            page += 1
        } catch {
            presentErrorToast(error)
        }
        isLoading = false
    }
    
    enum FetchType {
        case refresh
        case new
    }
}
