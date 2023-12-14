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
    
    struct GeoActivitiesResponseType: Decodable {
        let success: Bool
        let data: DataType
        
        struct DataType: Decodable {
            let activities: [MapActivity]
        }
    }
    func getGeoActivities(for region: MKCoordinateRegion) async throws -> [MapActivity] {
        let (ne, sw) = region.boundariesNESW
        
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let responseData = try await apiManager.requestData("/map/geoActivities", queryParams: [
            "northEastLat": String(ne.latitude),
            "northEastLng": String(ne.longitude),
            "southWestLat": String(sw.latitude),
            "southWestLng": String(sw.longitude)
        ], token: token) as GeoActivitiesResponseType?
        
        guard let responseData else {
            throw URLError(.badServerResponse)
        }
        
        return responseData.data.activities
    }
}
