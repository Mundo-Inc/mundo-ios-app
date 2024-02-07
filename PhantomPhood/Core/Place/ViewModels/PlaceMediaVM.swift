//
//  PlaceMediaVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation

@MainActor
class PlaceMediaVM: ObservableObject {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    private let placeDM = PlaceDM()
    
    let placeId: String
    
    init(placeId: String) {
        self.placeId = placeId
        Task {
            await fetch(type: .refresh)
        }
    }
    
    @Published var isLoading: Bool = false
    @Published var medias: [MediaWithUser] = []
    
    var page = 1
    func fetch(type: FetchType) async {
        if isLoading { return }

        if type == .refresh {
            page = 1
        }
        
        isLoading = true
        do {
            let data = try await placeDM.getMedias(id: placeId, page: page)
            
            if page == 1 {
                medias = data.data
            } else {
                medias.append(contentsOf: data.data)
            }
            page += 1
        } catch {
            print(error)
        }
        isLoading = false
    }
    
    enum FetchType {
        case refresh
        case new
    }
}
