//
//  FeedDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

struct FeedDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    enum FeedType: String {
        case followings
        case forYou
    }
    
    func getFeed(page: Int = 1, type: FeedType) async throws -> [FeedItem] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[FeedItem]> = try await apiManager.requestData("/feeds", method: .get, queryParams: [
            "page": String(page),
            "isForYou": type == .forYou ? "true" : nil
        ], token: token)
        
        return data.data
    }
}
