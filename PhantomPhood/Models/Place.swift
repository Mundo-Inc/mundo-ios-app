//
//  Place.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

/*
 _id: true,
 name: true,
 otherNames: true,
 description: true,
 location: true,
 phone: true,
 website: true,
 categories: true,
 thumbnail: true,
 priceRange: true,
 scores: true,
 reviewCount: true,
 */

struct PlaceScores: Decodable {
    let overall: Double?
    let drinkQuality: Double?
    let foodQuality: Double?
    let atmosphere: Double?
    let service: Double?
    let value: Double?
    let phantom: Double?
}

struct PlaceLocation: Decodable {
    struct GeoLocation: Decodable {
        let lng: Double
        let lat: Double
    }
    let geoLocation: GeoLocation
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let zip: String?
}

enum MediaType: String, Decodable {
    case image = "image"
    case video = "video"
}
struct Media: Identifiable, Decodable {
    let _id: String
    let src: String
    let caption: String?
    let type: MediaType
    
    var id: String {
        self._id
    }
}

struct Place: Identifiable, Decodable {
    let _id: String
    let name: String
    let otherNames: [String]
    let description: String?
    let location: PlaceLocation
    let thumbnail: String?
    let phone: String?
    let website: String?
    let categories: [String]
    let priceRange: Int?
    let scores: PlaceScores
    let reviewCount: Int
    
    // -
    let reviews: [Review]
    
    var id: String {
        self._id
    }
}

struct CompactPlace: Identifiable, Decodable {
    let _id: String
    let name: String
    let otherNames: [String]
    let description: String?
    let location: PlaceLocation
    let thumbnail: String?
    let phone: String?
    let website: String?
    let categories: [String]
    let priceRange: Int?
    let scores: PlaceScores
    let reviewCount: Int
    
    var id: String {
        self._id
    }
}

struct BriefPlace: Identifiable, Decodable {
    let _id: String
    let name: String
    let location: PlaceLocation
    let thumbnail: String?
    let categories: [String]
    
    var id: String {
        self._id
    }
}
