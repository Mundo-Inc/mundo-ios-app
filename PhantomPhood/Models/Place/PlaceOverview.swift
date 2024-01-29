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
    let thumbnail: String?
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
