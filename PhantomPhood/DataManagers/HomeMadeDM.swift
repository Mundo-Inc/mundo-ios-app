//
//  HomeMadeDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/13/24.
//

import Foundation

struct HomeMadeDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getHomemades() async throws -> [HomeMade] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[HomeMade]> = try await apiManager.requestData("/homemades", method: .get, token: token)
        
        return data.data
    }
    
    func createHomeMadeContent(body: CreateHomeMadeRequestBody) async throws {
        let token = try await auth.getToken()
        
        let requestBody = try apiManager.createRequestBody(body)
        try await apiManager.requestNoContent("/homemades", method: .post, body: requestBody, token: token)
    }
    
    func deleteOne(byId id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/homemades/\(id)", method: .delete, token: token)
    }
    
    // MARK: Structs
    
    struct CreateHomeMadeRequestBody: Encodable {
        let content: String
        let media: [UploadManager.MediaIds]
        let tags: [String]
    }
}
