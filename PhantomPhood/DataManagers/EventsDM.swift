//
//  EventsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation

struct EventsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getEvents(q: String? = nil) async throws -> [Event] {
        let token = try await auth.getToken()
        
        let data: APIResponse<[Event]> = try await apiManager.requestData("/events", queryParams: [
            "q": q != nil && !q!.isEmpty ? q! : nil
        ], token: token)
        
        return data.data
    }
    
    func getEvent(_ eventId: String) async throws -> Event {
        let token = try await auth.getToken()
        
        let data: APIResponse<Event> = try await apiManager.requestData("/events/\(eventId)", token: token)
        
        return data.data
    }
}
