//
//  MediaDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

final class MediaDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getMedia(event: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[MediaItem]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/media", queryParams: [
            "event": event,
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
    
    func getMedia(place: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[MediaItem]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[MediaItem]> = try await apiManager.requestData("/media", queryParams: [
            "place": place,
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
}
