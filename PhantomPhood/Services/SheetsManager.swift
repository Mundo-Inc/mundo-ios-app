//
//  SheetsManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/29/24.
//

import Foundation
import MapKit

@MainActor
final class SheetsManager: ObservableObject {
    static let shared = SheetsManager()
    
    private init() {}
    
    @Published var presenting: Sheet? = nil
    
    enum Sheet: Identifiable {
        case placeSelector(onSelect: (MKMapItem) -> Void)
        case reactionSelector(onSelect: (EmojisManager.Emoji) -> Void)
        case comments(activityId: String)
        case gifting(IdOrData<UserEssentials>)
        
        var id: String {
            switch self {
            case .placeSelector(let onSelect):
                return String(describing: onSelect)
            case .reactionSelector(let onSelect):
                return String(describing: onSelect)
            case .comments(let activityId):
                return activityId
            case .gifting(let idOrData):
                switch idOrData {
                case .id(let userId):
                    return userId
                case .data(let user):
                    return user.id
                }
            }
        }
    }
}
