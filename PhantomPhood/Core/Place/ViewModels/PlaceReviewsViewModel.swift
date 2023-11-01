//
//  PlaceReviewsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import Foundation

@MainActor
class PlaceReviewsViewModel: ObservableObject {
    let apiManager = APIManager()
    let auth: Authentication = Authentication.shared

    let placeId: String
    
    init(placeId: String) {
        self.placeId = placeId
    }
    
    @Published var isLoading: Bool = false
    @Published var reviews: [PlaceReview] = []
    
    var page = 1
    func fetch(type: FetchType) async {
        if isLoading { return }
        
        struct ReviewsResponse: Decodable {
            let success: Bool
            let total: Int
            let data: [PlaceReview]
        }
        
        isLoading = true
        
        if type == .refresh {
            page = 1
        }
        
        do {
            let data = try await apiManager.requestData("/places/\(placeId)/reviews?page=\(page)", token: auth.token) as ReviewsResponse?
            if let data = data {
                if page == 1 {
                    reviews = data.data
                } else {
                    reviews.append(contentsOf: data.data)
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
