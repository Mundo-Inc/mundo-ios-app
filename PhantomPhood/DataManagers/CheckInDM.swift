//
//  CheckInDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

struct CheckInDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getCheckins(event: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[CheckIn]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[CheckIn]> = try await apiManager.requestData("/checkins", queryParams: [
            "event": event,
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func getCheckins(user: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[CheckIn]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[CheckIn]> = try await apiManager.requestData("/checkins", queryParams: [
            "user": user,
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func getCheckins(place: String, page: Int = 1, limit: Int = 20) async throws -> APIResponseWithPagination<[CheckIn]> {
        let token = try await auth.getToken()
        
        let data: APIResponseWithPagination<[CheckIn]> = try await apiManager.requestData("/checkins", queryParams: [
            "place": place,
            "page": String(page),
            "limit": String(limit)
        ], token: token)
        
        return data
    }
    
    func checkin(placeId: String) async throws {
        let token = try await auth.getToken()
        
        struct RequestBody: Encodable {
            let place: String
        }
        
        let body = try apiManager.createRequestBody(RequestBody(place: placeId))
        try await apiManager.requestNoContent("/checkins", method: .post, body: body, token: token)
    }
    
    func checkin(body: CheckinRequestBody) async throws {
        let token = try await auth.getToken()
        
        let body = try apiManager.createRequestBody(body)
        try await apiManager.requestNoContent("/checkins", method: .post, body: body, token: token)
    }
    
    func deleteOne(byId id: String) async throws {
        let token = try await auth.getToken()
        
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
        let scores: Scores?
        
        init(place: String, privacyType: PrivacyType?, tags: [String]?, caption: String?, media: [String]?, scores: Scores?) {
            self.place = place
            self.event = nil
            self.privacyType = privacyType
            self.tags = tags
            self.caption = caption
            self.media = media
            self.scores = scores
        }
        
        init(event: String, privacyType: PrivacyType?, tags: [String]?, caption: String?, media: [String]?, scores: Scores?) {
            self.place = nil
            self.event = event
            self.privacyType = privacyType
            self.tags = tags
            self.caption = caption
            self.media = media
            self.scores = scores
        }
        
        struct Scores: Encodable {
            let overall: Int?
            let drinkQuality: Int?
            let foodQuality: Int?
            let service: Int?
            let atmosphere: Int?
            let value: Int?
        }
    }
}
