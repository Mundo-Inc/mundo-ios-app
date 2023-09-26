//
//  FeedDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

class FeedDataManager {
    let apiManager = APIManager()
    private let auth: Authentication = Authentication.shared
    
    func getFeed(page: Int = 1) async throws -> [FeedItem] {
        struct FeedResponse: Decodable {
            let success: Bool
            let result: [FeedItem]
        }
        
        guard let token = await auth.token else {
            fatalError("No token provided")
        }
        
        let (data, _) = try await apiManager.request("/feeds?page=\(page)", method: .get, token: token) as (FeedResponse?, HTTPURLResponse)
        
        if let data = data {
            return data.result
        } else {
            fatalError("Unable to get feed data")
        }
    }
}
