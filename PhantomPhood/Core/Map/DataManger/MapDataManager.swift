//
//  MapDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/12/23.
//

import Foundation

class MapDataManager {
    private let apiManager = APIManager()
    private let auth = Authentication.shared
    
    func fetchRegionPlaces(NElat: Double, NElng: Double, SWlat: Double, SWlng: Double) async throws -> [RegionPlace] {
        struct RegionPlacesResponse: Decodable {
            let success: Bool
            let data: ResponseData
            
            struct ResponseData: Decodable {
                let places: [RegionPlace]
            }
        }
        
        guard let token = await auth.token else {
            fatalError("No token")
        }
        
        let (data, _) = try await apiManager.request("/places/map?northEastLat=\(NElat)&northEastLng=\(NElng)&southWestLat=\(SWlat)&southWestLng=\(SWlng)", method: .get, token: token) as (RegionPlacesResponse?, HTTPURLResponse)

        guard let data = data else {
            fatalError("Couldn't get the data")
        }
        
        return data.data.places
    }
}
