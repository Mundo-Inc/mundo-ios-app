//
//  CheckInDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

final class CheckInDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getCheckins(event: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[Checkin]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[Checkin]> = try await apiManager.requestData("/checkins", queryParams: [
            "event": event,
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
    
    func getCheckins(user: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[Checkin]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[Checkin]> = try await apiManager.requestData("/checkins", queryParams: [
            "user": user,
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
    
    func getCheckins(place: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[Checkin]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[Checkin]> = try await apiManager.requestData("/checkins", queryParams: [
            "place": place,
            "page": page.description,
            "limit": limit.description
        ], token: token)
        
        return data
    }
    
    func checkin(id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct RequestBody: Encodable {
            let place: String
        }
        
        let body = try apiManager.createRequestBody(RequestBody(place: id))
        try await apiManager.requestNoContent("/checkins", method: .post, body: body, token: token)
    }
    
    func checkin(body: CheckinRequestBody) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let body = try apiManager.createRequestBody(body)
        try await apiManager.requestNoContent("/checkins", method: .post, body: body, token: token)
    }
    
    func deleteOne(byId id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/checkins/\(id)", method: .delete, token: token)
    }
    
    // MARK: - Structs
    
    struct CheckinRequestBody: Encodable {
        let place: String?
        let event: String?
        let privacyType: PrivacyType?
        let tags: [String]?
        let caption: String?
        let media: [String]?
        
        init(place: String, privacyType: PrivacyType?, tags: [String]?, caption: String?, media: [String]?) {
            self.place = place
            self.event = nil
            self.privacyType = privacyType
            self.tags = tags
            self.caption = caption
            self.media = media
        }
        
        init(event: String, privacyType: PrivacyType?, tags: [String]?, caption: String?, media: [String]?) {
            self.place = nil
            self.event = event
            self.privacyType = privacyType
            self.tags = tags
            self.caption = caption
            self.media = media
        }
    }
}
