//
//  ReportDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/9/24.
//

import Foundation

final class ReportDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    // MARK: - Public methods
    
    func report(item: ReportType, flagType: FlagType, note: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let body: Data
        
        switch item {
        case .activity(let id):
            body = try apiManager.createRequestBody(ReportRequestBody(activity: id, review: nil, comment: nil, homemade: nil, checkIn: nil, flagType: flagType.rawValue, note: note))
        case .review(let id):
            body = try apiManager.createRequestBody(ReportRequestBody(activity: nil, review: id, comment: nil, homemade: nil, checkIn: nil, flagType: flagType.rawValue, note: note))
        case .comment(let id):
            body = try apiManager.createRequestBody(ReportRequestBody(activity: nil, review: nil, comment: id, homemade: nil, checkIn: nil, flagType: flagType.rawValue, note: note))
        case .homemade(let id):
            body = try apiManager.createRequestBody(ReportRequestBody(activity: nil, review: nil, comment: nil, homemade: id, checkIn: nil, flagType: flagType.rawValue, note: note))
        case .checkIn(let id):
            body = try apiManager.createRequestBody(ReportRequestBody(activity: nil, review: nil, comment: nil, homemade: nil, checkIn: id, flagType: flagType.rawValue, note: note))
        }
        
        try await apiManager.requestNoContent("/activities/flag", method: .post, body: body, token: token)
    }
        
    // MARK: - Structs
    
    struct ReportRequestBody: Encodable {
        let activity: String?
        let review: String?
        let comment: String?
        let homemade: String?
        let checkIn: String?
        let flagType: String
        let note: String
    }
    
    enum ReportType: Hashable {
        case activity(String)
        case review(String)
        case comment(String)
        case homemade(String)
        case checkIn(String)
        
        var title: String {
            switch self {
            case .activity(_):
                return "Activity"
            case .review(_):
                return "Review"
            case .comment(_):
                return "Comment"
            case .homemade(_):
                return "Activity"
            case .checkIn(_):
                return "Check In"
            }
        }
    }

    enum FlagType: String, CaseIterable {
        case INAPPROPRIATE_CONTENT = "INAPPROPRIATE_CONTENT"
        case SPAM = "SPAM"
        case FALSE_INFORMATION = "FALSE_INFORMATION"
        case PERSONAL_INFORMATION = "PERSONAL_INFORMATION"
        case OFF_TOPIC = "OFF_TOPIC"
        case HARASSMENT = "HARASSMENT"
        case SUSPECTED_FAKE_REVIEW = "SUSPECTED_FAKE_REVIEW"
        case COPYRIGHT_VIOLATION = "COPYRIGHT_VIOLATION"
        case OTHER = "OTHER"
    }
}
