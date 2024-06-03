//
//  ReportDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/9/24.
//

import Foundation
import CryptoKit

final class ReportDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    struct CrashReport: Encodable {
        let function: String
        let file: String
        let line: Int
        let message: String
        
        func encrypt(with: String) -> String? {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(self)
                let keyData = SHA256.hash(data: Data(with.utf8))
                let key = SymmetricKey(data: keyData)
                let sealedBox = try AES.GCM.seal(jsonData, using: key)
                return sealedBox.combined?.base64EncodedString()
            } catch {
                print("Encryption error: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Public methods
    
    func reportBug(report: CrashReport) async throws {
        if let userId = auth.currentUser?.id {
            guard let token = await auth.getToken(),
                  let reportString = report.encrypt(with: userId) else {
                throw URLError(.userAuthenticationRequired)
            }
            
            struct CrashReportBody: Encodable {
                let body: String
            }
            
            let body = try apiManager.createRequestBody(CrashReportBody(body: reportString))
            try await apiManager.requestNoContent("/general/bug", method: .post, body: body, token: token)
        } else {
            let body = try apiManager.createRequestBody(report)
            try await apiManager.requestNoContent("/general/bug", method: .post, body: body)
        }
    }
    
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
