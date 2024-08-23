//
//  MediaDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

struct MediaDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getMedia(event: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[MediaItem]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/media", queryParams: [
            "event": event,
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func getMedia(place: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[MediaItem]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/media", queryParams: [
            "place": place,
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
}
