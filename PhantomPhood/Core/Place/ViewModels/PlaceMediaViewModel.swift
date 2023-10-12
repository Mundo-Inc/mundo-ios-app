//
//  PlaceMediaViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation

@MainActor
class PlaceMediaViewModel: ObservableObject {
    let apiManager = APIManager()
    let auth = Authentication.shared
    
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
        
        struct ReviewsResponse: Decodable {
            let success: Bool
            let total: Int
            let data: [MediaWithUser]
        }
        
        isLoading = true
        
        if type == .refresh {
            page = 1
        }
        
        do {
            let (data, _) = try await apiManager.request("/places/\(placeId)/media?page=\(page)", token: auth.token) as (ReviewsResponse?, HTTPURLResponse)
            if let data = data {
                if page == 1 {
                    medias = data.data
                } else {
                    medias.append(contentsOf: data.data)
                }
                page += 1
            }
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
