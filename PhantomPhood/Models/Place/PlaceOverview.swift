//
//  PlaceOverview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct PlaceOverview: Identifiable, Decodable {
    let id: String
    let name: String
    let amenity: PlaceAmenity?
    let description: String?
    let location: PlaceLocation
    let thumbnail: URL?
    let phone: String?
    let website: String?
    let categories: [String]
    let priceRange: Int?
    let scores: PlaceScores
    let activities: Activities
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, amenity, description, location, thumbnail, phone, website, categories, priceRange, scores, activities
    }
    
    struct Activities: Decodable {
        let reviewCount: Int
        let checkinCount: Int
    }
}

extension PlaceOverview {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amenity = try container.decodeIfPresent(PlaceAmenity.self, forKey: .amenity)
        description = try container.decodeOptionalString(forKey: .description)
        location = try container.decode(PlaceLocation.self, forKey: .location)
        phone = try container.decodeOptionalString(forKey: .phone)
        website = try container.decodeOptionalString(forKey: .website)
        categories = try container.decode([String].self, forKey: .categories)
        priceRange = try container.decodeIfPresent(Int.self, forKey: .priceRange)
        scores = try container.decode(PlaceScores.self, forKey: .scores)
        activities = try container.decode(Activities.self, forKey: .activities)
        thumbnail = try container.decodeURLIfPresent(forKey: .thumbnail)
    }
}

extension PlaceOverview {
    init(placeDetail: PlaceDetail) {
        self.id = placeDetail.id
        self.name = placeDetail.name
        self.amenity = placeDetail.amenity
        self.description = placeDetail.description
        self.location = placeDetail.location
        self.thumbnail = placeDetail.thumbnail
        self.phone = placeDetail.phone
        self.website = placeDetail.website
        self.categories = placeDetail.categories
        self.priceRange = placeDetail.priceRange
        self.scores = placeDetail.scores
        self.activities = placeDetail.activities
    }
}
