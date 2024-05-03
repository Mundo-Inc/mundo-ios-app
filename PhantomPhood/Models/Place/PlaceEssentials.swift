//
//  PlaceEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation
import CoreData
import MapKit

struct PlaceEssentials: Identifiable, Decodable {
    let id: String
    let name: String
    let location: PlaceLocation
    let thumbnail: URL?
    let categories: [String]
    
    var coordinates: CLLocationCoordinate2D {
        .init(latitude: location.geoLocation.lat, longitude: location.geoLocation.lng)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, location, thumbnail, categories
    }
}

extension PlaceEssentials {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(PlaceLocation.self, forKey: .location)
        categories = try container.decode([String].self, forKey: .categories)
        
        if let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnail), !thumbnailString.isEmpty {
            thumbnail = URL(string: thumbnailString)
        } else {
            thumbnail = nil
        }
    }
}

extension PlaceEssentials {
    init (placeDetail: PlaceDetail) {
        self.id = placeDetail.id
        self.name = placeDetail.name
        self.location = placeDetail.location
        self.thumbnail = placeDetail.thumbnail
        self.categories = placeDetail.categories
    }
}

extension PlaceEssentials {
    init (placeOverview: PlaceOverview) {
        self.id = placeOverview.id
        self.name = placeOverview.name
        self.location = placeOverview.location
        self.thumbnail = placeOverview.thumbnail
        self.categories = placeOverview.categories
    }
}

extension PlaceEssentials {
    init(_ entity: PlaceEntity) {
        id = entity.id ?? ""
        name = entity.name ?? ""
        location = .init(geoLocation: .init(lng: entity.longitude, lat: entity.latitude), address: nil, city: nil, state: nil, country: nil, zip: nil)
        thumbnail = entity.thumbnail != nil ? URL(string: entity.thumbnail!) : nil
        categories = []
    }
    
    func createPlaceEntity(context: NSManagedObjectContext) -> PlaceEntity {
        var placeEntity: PlaceEntity!
        
        context.performAndWait {
            placeEntity = PlaceEntity(context: context)
            placeEntity.id = self.id
            placeEntity.name = self.name
            placeEntity.thumbnail = self.thumbnail?.absoluteString
            placeEntity.latitude = self.location.geoLocation.lat
            placeEntity.longitude = self.location.geoLocation.lng
            placeEntity.savedAt = .now
            
            do {
                try context.obtainPermanentIDs(for: [placeEntity])
            } catch {
                presentErrorToast(error, debug: "Error obtaining a permanent ID for userEntity", silent: true)
            }
        }
        
        return placeEntity
        
    }
}
