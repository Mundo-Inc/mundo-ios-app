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
    let geoLocation: GeoLocation
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let zip: String?
    
    struct GeoLocation: Decodable {
        let lng: Double
        let lat: Double
    }
}

struct PlaceDetail: Identifiable, Decodable {
    let id: String
    let name: String
    let amenity: PlaceAmenity?
    let otherNames: [String]
    let description: String?
    let location: PlaceLocation
    let thumbnail: URL?
    let phone: String?
    let website: String?
    let categories: [String]
    let priceRange: Int?
    let scores: PlaceScores
    let activities: PlaceOverview.Activities
    
    let thirdParty: ThirdPartyResult
    let media: [Media]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, amenity, otherNames, description, location, thumbnail, phone, website, categories, priceRange, scores, activities, thirdParty, media
    }
}

extension PlaceDetail {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        otherNames = try container.decode([String].self, forKey: .otherNames)
        location = try container.decode(PlaceLocation.self, forKey: .location)
        categories = try container.decode([String].self, forKey: .categories)
        scores = try container.decode(PlaceScores.self, forKey: .scores)
        thirdParty = try container.decode(ThirdPartyResult.self, forKey: .thirdParty)
        activities = try container.decode(PlaceOverview.Activities.self, forKey: .activities)
        media = try container.decode([Media].self, forKey: .media)
        
        amenity = try container.decodeIfPresent(PlaceAmenity.self, forKey: .amenity)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        priceRange = try container.decodeIfPresent(Int.self, forKey: .priceRange)

        if let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnail), !thumbnailString.isEmpty {
            thumbnail = URL(string: thumbnailString)
        } else {
            thumbnail = nil
        }
    }
}

extension PlaceDetail {
    
    // MARK: - Structs
    
    struct GoogleResult: Decodable {
        let rating: Double
        let reviewCount: Int
        let thumbnail: URL?
        let openingHours: OpenningHours?
        
        struct OpenningHours: Decodable {
            let openNow: Bool
            let periods: [Periods]
            let weekdayDescriptions: [String]
            
            struct Periods: Decodable {
                let close: DayTime
                let open: DayTime
                
                struct DayTime: Decodable {
                    let day: Int
                    let hour: Int
                    let minute: Int
                }
            }
        }
    }
    
    struct YelpResult: Decodable, Identifiable {
        let id: String
        let reviewCount: Int
        let rating: Double
        let phone: String
        let photos: [String]
        let url: String?
        let thumbnail: URL?
        let categories: [YCategory]?
        let transactions: [String]?
        let price: String?
        
        /// Yelp Category
        struct YCategory: Decodable {
            let title: String
            let alias: String
        }
    }
    
    struct ThirdPartyResult: Decodable {
        let google: GoogleResult?
        let yelp: YelpResult?
    }
}
