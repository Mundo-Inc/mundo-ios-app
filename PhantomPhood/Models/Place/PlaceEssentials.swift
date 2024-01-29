//
//  PlaceEssentials.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct PlaceEssentials: Identifiable, Decodable {
    let id: String
    let name: String
    let location: PlaceLocation
    let thumbnail: String?
    let categories: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, location, thumbnail, categories
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
