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
        
        let data: APIResponse<[HomeMade]> = try await apiManager.requestData("/homemades", method: .get, token: token)
        
        return data.data
    }
    
    func createHomeMadeContent(body: CreateHomeMadeRequestBody) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let requestBody = try apiManager.createRequestBody(body)
        try await apiManager.requestNoContent("/homemades", method: .post, body: requestBody, token: token)
    }
    
    func deleteOne(byId id: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        try await apiManager.requestNoContent("/homemades/\(id)", method: .delete, token: token)
    }
    
    // MARK: Structs
    
    struct CreateHomeMadeRequestBody: Encodable {
        let content: String
        let media: [UploadManager.MediaIds]
        let tags: [String]
    }
}
