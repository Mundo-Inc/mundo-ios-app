//
//  PlaceIdentifier.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/29/24.
//

import Foundation
import MapKit

enum PlaceIdentifier: Hashable {
    static func == (lhs: PlaceIdentifier, rhs: PlaceIdentifier) -> Bool {
        switch (lhs, rhs) {
        case let (.mapPlace(p1), .mapPlace(p2)):
            return p1.title == p2.title && p1.coordinate == p2.coordinate
        default:
            return lhs.getId() == rhs.getId()
        }
    }
    
    static let coordinatePrecision: Int = 6
    static let placeDM = PlaceDM()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("place")
        switch self {
        case .id(let id):
            hasher.combine(id)
        case .essentials(let placeEssentials):
            hasher.combine(placeEssentials.id)
        case .overview(let placeOverview):
            hasher.combine(placeOverview.id)
        case .detail(let placeDetail):
            hasher.combine(placeDetail.id)
        case .mapPlace(let mapPlace):
            hasher.combine(mapPlace.title)
            hasher.combine(mapPlace.coordinate.latitude)
            hasher.combine(mapPlace.coordinate.longitude)
        }
    }
    
    case id(String)
    case essentials(PlaceEssentials)
    case overview(PlaceOverview)
    case detail(PlaceDetail)
    case mapPlace(MapPlace)
    
    func getId() -> String? {
        switch self {
        case .id(let id):
            return id
        case .essentials(let placeEssentials):
            return placeEssentials.id
        case .overview(let placeOverview):
            return placeOverview.id
        case .detail(let placeDetail):
            return placeDetail.id
        case .mapPlace(_):
            return nil
        }
    }
    
    func getId() async throws -> String {
        switch self {
        case .id(let id):
            return id
        case .essentials(let placeEssentials):
            return placeEssentials.id
        case .overview(let placeOverview):
            return placeOverview.id
        case .detail(let placeDetail):
            return placeDetail.id
        case .mapPlace(_):
            let data = try await self.getEssentials()
            return data.id
        }
    }
    
    func getEssentials() async throws -> PlaceEssentials {
        switch self {
        case .id(let id):
            let data = try await Self.placeDM.getOverview(id: id)
            return PlaceEssentials(placeOverview: data)
        case .essentials(let placeEssentials):
            return placeEssentials
        case .overview(let placeOverview):
            return PlaceEssentials(placeOverview: placeOverview)
        case .detail(let placeDetail):
            return PlaceEssentials(placeDetail: placeDetail)
        case .mapPlace(let mapPlace):
            let data = try await Self.placeDM.fetch(mapPlace: mapPlace)
            return PlaceEssentials(placeDetail: data)
        }
    }
    
    func getOverview() async throws -> PlaceOverview {
        switch self {
        case .id(let id):
            let data = try await Self.placeDM.getOverview(id: id)
            return data
        case .essentials(let placeEssentials):
            let data = try await Self.placeDM.getOverview(id: placeEssentials.id)
            return data
        case .overview(let placeOverview):
            return placeOverview
        case .detail(let placeDetail):
            return PlaceOverview(placeDetail: placeDetail)
        case .mapPlace(let mapPlace):
            let data = try await Self.placeDM.fetch(mapPlace: mapPlace)
            return PlaceOverview(placeDetail: data)
        }
    }
    
    func getDetail() async throws -> PlaceDetail {
        switch self {
        case .id(let id):
            let data = try await Self.placeDM.fetch(id: id)
            return data
        case .essentials(let placeEssentials):
            let data = try await Self.placeDM.fetch(id: placeEssentials.id)
            return data
        case .overview(let placeOverview):
            let data = try await Self.placeDM.fetch(id: placeOverview.id)
            return data
        case .detail(let placeDetail):
            return placeDetail
        case .mapPlace(let mapPlace):
            let data = try await Self.placeDM.fetch(mapPlace: mapPlace)
            return data
        }
    }
    
    static func generateID(for name: String, with coordinate: CLLocationCoordinate2D) throws -> String? {
        let formattedLatitude = String(format: "%.\(coordinatePrecision)f", coordinate.latitude)
        let formattedLongitude = String(format: "%.\(coordinatePrecision)f", coordinate.longitude)
        let baseString = "\(name)_\(formattedLatitude)_\(formattedLongitude)"
        
        guard let encodedData = baseString.data(using: .utf8) else {
            return nil
        }
        
        return encodedData.base64EncodedString()
    }
}
