//
//  FeedDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

final class FeedDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    enum FeedType: String {
        case followings
        case forYou
    }
    
    func getFeed(page: Int = 1, type: FeedType) async throws -> [FeedItem] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<[FeedItem]> = try await apiManager.requestData("/feeds", method: .get, queryParams: [
            "page": page.description,
            "isForYou": type == .forYou ? "true" : nil
        ], token: token)
        
        return data.data
    }
}
