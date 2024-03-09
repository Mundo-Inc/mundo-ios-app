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
    
    func getMedia(event: String, page: Int = 1, limit: Int = 20) async throws -> [MediaWithUser] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let data = try await apiManager.requestData("/media?event=\(event)&page=\(page)&limit=\(limit)", token: token) as APIResponse<[MediaWithUser]>? else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getMedia(place: String, page: Int = 1, limit: Int = 20) async throws -> [MediaWithUser] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let data = try await apiManager.requestData("/media?place=\(place)&page=\(page)&limit=\(limit)", token: token) as APIResponse<[MediaWithUser]>? else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
}
