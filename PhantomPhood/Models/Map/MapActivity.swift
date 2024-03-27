//
//  MapActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/12/23.
//

import Foundation
import MapKit

struct MapActivity: Identifiable, Decodable {
    let id: String
    let place: PlaceEssentials
    let user: UserEssentials
    let activityType: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case place, user, activityType, createdAt
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.place.coordinates
    }
}

extension MapActivity {
    init(_ entity: MapActivityEntity) {
        self.id = entity.id!
        self.place = PlaceEssentials(entity.place!)
        self.user = UserEssentials(entity.user!)
        self.activityType = entity.activityType!
        self.createdAt = entity.createdAt!
    }
}
