//
//  Place.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation
import SwiftUI

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

struct MediaWithUser: Identifiable, Decodable {
    let _id: String
    let src: String
    let caption: String?
    let type: MediaType
    let user: User?
    // TODO: When we remove third party media we can change this to not-optional
    
    var id: String {
        self._id
    }
}


struct Place: Identifiable, Decodable {
    struct GoogleResults: Decodable {
        struct GoogleReviews: Decodable {
            let author_name: String
            let language: String?
            let original_language: String
            let profile_photo_url: String?
            let rating: Int
            let relative_time_description: String
            let text: String
            let time: Int
            let translated: Bool
        }
        
        let rating: Double
        let reviewCount: Int
        let reviews: [GoogleReviews]?
        let thumbnail: String?
    }
    
    struct YelpResults: Decodable {
        struct YelpReviews: Identifiable, Decodable {
            struct YelpUser: Identifiable, Decodable {
                let id: String
                let profile_url: String
                let image_url: String?
                let name: String
            }
            
            let id: String
            let url: String
            let text: String
            let rating: Int
            let time_created: String
            let user: YelpUser
        }
        
        let rating: Double
        let reviewCount: Int
        let reviews: [YelpReviews]?
        let thumbnail: String?
    }

    
    struct ThirdPartyResults: Decodable {
        let google: GoogleResults?
        let yelp: YelpResults?
    }
    
    let _id: String
    let name: String
    let amenity: PlaceAmenity?
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
    let reviews: [PlaceReview]
    let thirdParty: ThirdPartyResults
    let media: [Media]
    
    var id: String {
        self._id
    }
}

struct CompactPlace: Identifiable, Decodable {
    let _id: String
    let name: String
    let amenity: PlaceAmenity?
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


struct RegionPlace: Identifiable, Decodable {
    let _id: String
    let name: String
    let amenity: PlaceAmenity?
    let longitude: Double
    let latitude: Double
    let overallScore: Double?
    let phantomScore: Double?
    
    var id: String {
        self._id
    }
}

enum PlaceAmenity: String, Decodable {
    case bar = "bar"
    case pub = "pub"
    case nightclub = "nightclub"
    case cafe = "cafe"
    case biergarten = "biergarten"
    case restaurant = "restaurant"
    case fast_food = "fast_food"
    case canteen = "canteen"
    case ice_cream = "ice_cream"
    case cafeteria = "cafeteria"
    case unknown
    
    var color: Color {
        switch self {
        case .bar:
            return Color(red: 1, green: 0.3, blue: 0.3)
        case .pub:
            return Color(red: 0.64, green: 0.16, blue: 0.16)
        case .nightclub:
            return Color(red: 0.4, green: 0.1, blue: 0.8)
        case .cafe:
            return Color(red: 0.44, green: 0.23, blue: 0)
        case .biergarten:
            return Color(red: 0.2, green: 0.6, blue: 0.2)
        case .restaurant:
            return Color(red: 1, green: 0.63, blue: 0.21)
        case .fast_food:
            return Color(red: 1, green: 0.9, blue: 0)
        case .canteen:
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        case .ice_cream:
            return Color(red: 1, green: 1, blue: 0.8)
        case .cafeteria:
            return Color(red: 0.8, green: 0.5, blue: 0.3)
        case .unknown:
            return Color.black
        }
    }
    
    var image: String {
        switch self {
        case .bar:
            "wineglass.fill"
        case .pub:
            "mug.fill"
        case .nightclub:
            "figure.socialdance"
        case .cafe:
            "cup.and.saucer.fill"
        case .biergarten:
            "mug.fill"
        case .restaurant:
            "fork.knife.circle.fill"
        case .fast_food:
            "fork.knife"
        case .canteen:
            "chair.fill"
        case .ice_cream: // TODO: change Icon
            "cone.fill"
        case .cafeteria:
            "cup.and.saucer.fill"
        case .unknown:
            "pin"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        if let value = value, let amenity = PlaceAmenity(rawValue: value) {
            self = amenity
        } else {
            self = .unknown
        }
    }
}
