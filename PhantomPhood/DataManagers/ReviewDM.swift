//
//  ReviewDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/1/24.
//

import Foundation

final class ReviewDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func getReview(reviewId: String) async throws -> APIResponseWithPagination<PlaceReview> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<PlaceReview> = try await apiManager.requestData("/reviews/\(reviewId)", token: token)
        
        return data
    }
    
    func getReviews(writer: String, sort: ReviewSort, page: Int = 1, limit: Int = 10) async throws -> APIResponseWithPagination<[PlaceReview]> {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponseWithPagination<[PlaceReview]> = try await apiManager.requestData("/reviews?writer=\(writer)&page=\(page)&limit=\(limit)&sort=\(sort.rawValue)", token: token)
        
        return data
    }
    
    func addReview(_ reviewBody: AddReviewRequestBody) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let body = try self.apiManager.createRequestBody(reviewBody)
        try await self.apiManager.requestNoContent("/reviews", method: .post, body: body, token: token)
    }
    
    func remove(reviewId: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/reviews/\(reviewId)", method: .delete, token: token)
    }
    
    struct AddReviewRequestBody: Encodable {
        let place: String
        let scores: ScoresBody
        let content: String
        let recommend: Bool?
        let images: [UploadManager.MediaIds]
        let videos: [UploadManager.MediaIds]
        
        struct ScoresBody: Encodable {
            let overall: Int?
            let drinkQuality: Int?
            let foodQuality: Int?
            let service: Int?
            let atmosphere: Int?
            let value: Int?
        }
    }
    
    enum ReviewSort: String {
        case newest
        case oldest
    }
}
