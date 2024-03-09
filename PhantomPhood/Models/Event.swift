//
//  Event.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import Foundation
import CoreLocation

struct Event: Identifiable, Decodable {
    let id: String
    let name: String
    let description: String?
    let logo: URL?
    let place: PlaceEssentials

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, logo, place
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: place.location.geoLocation.lat, longitude: place.location.geoLocation.lng)
    }
}

extension Event: Equatable, Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension Event {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        place = try container.decode(PlaceEssentials.self, forKey: .place)

        if let logoString = try container.decodeIfPresent(String.self, forKey: .logo), !logoString.isEmpty {
            logo = URL(string: logoString)
        } else {
            logo = nil
        }
    }
}
