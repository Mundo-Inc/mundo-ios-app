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
    
    func report(id: String, type: ReportType, flagType: FlagType, note: String) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let body = try apiManager.createRequestBody(ReportRequestBody(flagType: flagType.rawValue, note: note))
        try await apiManager.requestNoContent("/\(type == .review ? "reviews" : "comments")/\(id)/flag", method: .post, body: body, token: token)
    }
        
    // MARK: - Structs
    
    struct ReportRequestBody: Encodable {
        let flagType: String
        let note: String
    }
    
    enum ReportType: String {
        case review = "Review"
        case comment = "Comment"
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
