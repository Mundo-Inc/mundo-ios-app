//
//  ListsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation

/// Lists Data Manager
struct ListsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    // MARK: - Public methods
    
    /// Get UserPlacesList
    /// - Parameter forUserId: User Id
    /// - Returns: Array of UserPlacesList
    func getUserLists(forUserId userId: String) async throws -> [CompactUserPlacesList] {
        let token = try await auth.getToken()
        
        let resData: APIResponse<[CompactUserPlacesList]> = try await apiManager.requestData("/users/\(userId)/lists", method: .get, token: token)
        
        return resData.data
    }
    
    /// Get a single UserPlacesList
    /// - Parameter id: List Id
    /// - Returns: UserPlacesList
    func getList(withId id: String) async throws -> UserPlacesList {
        let token = try await auth.getToken()
        
        let resData: APIResponse<UserPlacesList> = try await apiManager.requestData("/lists/\(id)", method: .get, token: token)
        
        return resData.data
    }
    
    /// Create a new UserPlacesList
    /// - Parameter body: CreateListBody
    /// - Returns: UserPlacesList
    func createList(body: CreateListBody) async throws -> UserPlacesList {
        let token = try await auth.getToken()
        
        let requestBody = try apiManager.createRequestBody(body)
        let resData: APIResponse<UserPlacesList> = try await apiManager.requestData("/lists", method: .post, body: requestBody, token: token)
        
        return resData.data
    }
    
    /// Edit a UserPlacesList (name, icon, isPrivate)
    /// - Note: All fields are optional
    /// - Parameters:
    ///   - id: List Id
    ///   - body: EditListBody
    /// - Returns: CompactUserPlacesList
    @discardableResult
    func editListInfo(withId id: String, body: EditListBody) async throws -> CompactUserPlacesList {
        let token = try await auth.getToken()
        
        let requestBody = try apiManager.createRequestBody(body)
        let resData: APIResponse<CompactUserPlacesList> = try await apiManager.requestData("/lists/\(id)", method: .put, body: requestBody, token: token)
        
        return resData.data
    }
    
    
    /// Add a place to a UserPlacesList
    /// - Parameters:
    ///   - listId: List Id
    ///   - placeId: Place Id
    func addPlaceToList(listId: String, placeId: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/lists/\(listId)/place/\(placeId)", method: .post, token: token)
    }
    
    /// Remove a place from a UserPlacesList
    /// - Parameters:
    ///   - listId: List Id
    ///   - placeId: Place Id
    func removePlaceFromList(listId: String, placeId: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/lists/\(listId)/place/\(placeId)", method: .delete, token: token)
    }
    
    /// Add a collaborator to a UserPlacesList
    /// - Parameters:
    ///   - listId: List Id
    ///   - userId: User Id
    ///   - access: ListCollaborator.Access (view or edit)
    func addCollaborator(listId: String, userId: String, access: ListCollaborator.Access) async throws {
        let token = try await auth.getToken()
        
        struct AddCollaboratorRequestBody: Encodable {
            let access: String
        }
        let requestBody = try apiManager.createRequestBody(AddCollaboratorRequestBody(access: access.rawValue))
        
        try await apiManager.requestNoContent("/lists/\(listId)/collaborator/\(userId)", method: .post, body: requestBody, token: token)
    }
    
    /// Edit a collaborator's access to a UserPlacesList
    /// - Parameters:
    ///   - listId: List Id
    ///   - userId: User Id
    ///   - access: ListCollaborator.Access (view or edit)
    func editCollaborator(listId: String, userId: String, changeAccessTo access: ListCollaborator.Access) async throws {
        let token = try await auth.getToken()
        
        struct AddCollaboratorRequestBody: Encodable {
            let access: String
        }
        let requestBody = try apiManager.createRequestBody(AddCollaboratorRequestBody(access: access.rawValue))
        
        try await apiManager.requestNoContent("/lists/\(listId)/collaborator/\(userId)", method: .put, body: requestBody, token: token)
    }
    
    /// Remove a collaborator from a UserPlacesList
    /// - Parameters:
    ///   - listId: List Id
    ///   - userId: User Id
    func removeCollaborator(listId: String, userId: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/lists/\(listId)/collaborator/\(userId)", method: .delete, token: token)
    }
    
    /// delete a UserPlacesList
    /// - Parameter id: List Id
    func deleteList(withId id: String) async throws {
        let token = try await auth.getToken()
        
        try await apiManager.requestNoContent("/lists/\(id)", method: .delete, token: token)
    }
    
    // MARK: - Structs
    
    struct CreateListBody: Encodable {
        let name: String
        let icon: String?
        let collaborators: [Collaborators]
        let isPrivate: Bool
        
        struct Collaborators: Encodable {
            let user: String
            let access: String
        }
    }
    
    struct EditListBody: Encodable {
        let name: String?
        let icon: String?
        let isPrivate: Bool?
    }
}
