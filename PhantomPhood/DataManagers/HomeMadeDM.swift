//
//  HomeMadeDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/13/24.
//

import Foundation

final class HomeMadeDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getHomemades() async throws -> [HomeMade] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data = try await apiManager.requestData("/homemades", method: .get, token: token) as APIResponse<[HomeMade]>?
        
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func createHomeMadeContent(body: CreateHomeMadeRequestBody) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let requestBody = try apiManager.createRequestBody(body)
        try await apiManager.requestNoContent("/homemades", method: .post, body: requestBody, token: token)
    }
    
    struct CreateHomeMadeRequestBody: Encodable {
        let content: String
        let media: [UploadManager.MediaIds]
        let tags: [String]
    }
}
