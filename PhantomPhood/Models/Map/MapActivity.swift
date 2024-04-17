//
//  MapActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/12/23.
//

import Foundation
import MapKit
import CoreData

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
    
    @discardableResult
    func createMapActivityEntity(context: NSManagedObjectContext, user: UserEntity, place: PlaceEntity) -> MapActivityEntity {
        let mapActivityEntity = MapActivityEntity(context: context)
        mapActivityEntity.id = self.id
        mapActivityEntity.activityType = self.activityType
        mapActivityEntity.createdAt = self.createdAt
        mapActivityEntity.user = user
        mapActivityEntity.place = place
        mapActivityEntity.savedAt = .now
        
        do {
            try context.obtainPermanentIDs(for: [mapActivityEntity])
        } catch {
            presentErrorToast(error, debug: "Error obtaining a permanent ID for userEntity", silent: true)
        }
        
        user.addToMapActivities(mapActivityEntity)
        place.addToMapActivities(mapActivityEntity)
        
        return mapActivityEntity
    }
}

extension MapActivity {
    init(_ entity: MapActivityEntity) throws {
        if let id = entity.id, let activityType = entity.activityType, let place = entity.place, let user = entity.user, let createdAt = entity.createdAt {
            self.id = id
            self.place = PlaceEssentials(place)
            self.user = UserEssentials(user)
            self.activityType = activityType
            self.createdAt = createdAt
        } else {
            throw EntityError.missingStructRequiredData
        }
    }
}
