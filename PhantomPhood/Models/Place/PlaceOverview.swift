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
    let reviewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, amenity, description, location, thumbnail, phone, website, categories, priceRange, scores, reviewCount
    }
}

extension PlaceOverview {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amenity = try container.decodeIfPresent(PlaceAmenity.self, forKey: .amenity)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        location = try container.decode(PlaceLocation.self, forKey: .location)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        categories = try container.decode([String].self, forKey: .categories)
        priceRange = try container.decodeIfPresent(Int.self, forKey: .priceRange)
        scores = try container.decode(PlaceScores.self, forKey: .scores)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)

        if let thumbnailString = try container.decodeIfPresent(String.self, forKey: .thumbnail), !thumbnailString.isEmpty {
            thumbnail = URL(string: thumbnailString)
        } else {
            thumbnail = nil
        }
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
        self.reviewCount = placeDetail.reviewCount
    }
}
