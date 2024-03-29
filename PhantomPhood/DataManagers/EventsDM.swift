//
//  EventsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

final class EventsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getEvents(q: String? = nil) async throws -> [Event] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let data = try await apiManager.requestData("/events\((q != nil && !q!.isEmpty) ? "?q=\(q!)" : "")", token: token) as APIResponse<[Event]>? else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
    
    func getEvent(_ eventId: String) async throws -> Event {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let data = try await apiManager.requestData("/events/\(eventId)", token: token) as APIResponse<Event>? else {
            throw URLError(.badServerResponse)
        }
        
        return data.data
    }
}
