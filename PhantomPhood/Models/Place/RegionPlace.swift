//
//  RegionPlace.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct RegionPlace: Identifiable, Decodable {
    let id: String
    let name: String
    let amenity: PlaceAmenity?
    let longitude: Double
    let latitude: Double
    let overallScore: Double?
    let phantomScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, amenity, longitude, latitude, overallScore, phantomScore
    }
}
