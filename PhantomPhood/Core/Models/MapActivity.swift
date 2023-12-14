//
//  MapActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/12/23.
//

import Foundation
import CoreLocation

struct MapActivity: Decodable, Identifiable, CoordinateRepresentable {
    let placeId: String
    let coordinates: [Double]
    let activities: Activities
    
    var longitude: CLLocationDegrees {
        self.coordinates.first ?? 0
    }
    var latitude: CLLocationDegrees {
        self.coordinates.last ?? 0
    }
    var id: String {
        self.placeId
    }
    
    var locationCoordinate: CLLocationCoordinate2D {
        return .init(latitude: latitude, longitude: longitude)
    }
    
    struct Activities: Decodable {
        let reviewCount: Int
        let checkinCount: Int
        let data: [ActivitiesData]
    }
    
    struct ActivitiesData: Decodable {
        let name: String
        let profileImage: String
        let checkinsCount: Int
        let reviewsCount: Int
    }
}
