//
//  PlaceAmenity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation
import SwiftUI

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
            "fork.knife"
        case .fast_food:
            "fork.knife.circle.fill"
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
