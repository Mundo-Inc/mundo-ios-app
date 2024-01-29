//
//  Place.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

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

struct PlaceDetail: Identifiable, Decodable {
    let id: String
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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, amenity, otherNames, description, location, thumbnail, phone, website, categories, priceRange, scores, reviewCount, reviews, thirdParty, media
    }
}

extension PlaceDetail {
    
    // MARK: - Structs
    
    struct GoogleResults: Decodable {
        let rating: Double
        let reviewCount: Int
        let reviews: [GoogleReviews]?
        let thumbnail: String?
        
        struct GoogleReviews: Decodable {
            let author_name: String
            let language: String?
            let original_language: String?
            let profile_photo_url: String?
            let rating: Int
            let relative_time_description: String
            let text: String
            let time: Int
            let translated: Bool
        }
    }
    
    struct YelpResults: Decodable {
        let rating: Double
        let reviewCount: Int
        let reviews: [YelpReviews]?
        let thumbnail: String?
        
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
    }
    
    struct ThirdPartyResults: Decodable {
        let google: GoogleResults?
        let yelp: YelpResults?
    }
}
