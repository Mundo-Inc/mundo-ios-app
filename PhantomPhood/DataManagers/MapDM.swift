//
//  MapDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/12/23.
//

import Foundation
import MapKit

final class MapDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
        
    func getMapActivities(ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D, startDate: Date, scope: Scope) async throws -> [MapActivity] {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let responseData: APIResponse<[MapActivity]> = try await apiManager.requestData("/map/mapActivities", queryParams: [
            "northEastLat": String(ne.latitude),
            "northEastLng": String(ne.longitude),
            "southWestLat": String(sw.latitude),
            "southWestLng": String(sw.longitude),
            "startDate": String(Int(startDate.timeIntervalSince1970 * 1000)),
            "scope": scope.rawValue
        ], token: token)
        
        return responseData.data
    }
    
    enum Scope: String, CaseIterable {
        case global = "GLOBAL"
        case followings = "FOLLOWINGS"
        
        var title: String {
            switch self {
            case .global:
                "Global"
            case .followings:
                "Followings"
            }
        }
    }
}
