//
//  PlaceIdentifier.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/29/24.
//

import Foundation
import MapKit

struct PlaceIdentifier: Identifiable {
    private static let coordinatePrecision = 6
    
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    init(mapItem: MKMapItem) throws {
        guard let name = mapItem.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            throw PlaceIdentifierError.nameIsEmpty
        }
        
        self.id = try PlaceIdentifier.generateID(for: name, with: mapItem.placemark.coordinate)
        self.name = name
        self.coordinate = mapItem.placemark.coordinate
    }
    
    init(id: String) throws {
        guard let data = Data(base64Encoded: id),
              let decodedString = String(data: data, encoding: .utf8) else {
            throw PlaceIdentifierError.idDecodingFailed
        }
        
        let components = decodedString.split(separator: "_")
        guard components.count == 3,
              let latitude = Double(components[1]),
              let longitude = Double(components[2]) else {
            throw PlaceIdentifierError.idFormatInvalid
        }
        
        guard !components[0].isEmpty else {
            throw PlaceIdentifierError.nameIsEmpty
        }
        
        self.id = id
        self.name = String(components[0])
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D) throws {
        guard !name.isEmpty else {
            throw PlaceIdentifierError.nameIsEmpty
        }
        
        self.id = try PlaceIdentifier.generateID(for: name, with: coordinate)
        self.name = name
        self.coordinate = coordinate
    }
}

extension PlaceIdentifier {
    private static func generateID(for name: String, with coordinate: CLLocationCoordinate2D) throws -> String {
        let formattedLatitude = String(format: "%.\(coordinatePrecision)f", coordinate.latitude)
        let formattedLongitude = String(format: "%.\(coordinatePrecision)f", coordinate.longitude)
        let baseString = "\(name)_\(formattedLatitude)_\(formattedLongitude)"
        
        guard let encodedData = baseString.data(using: .utf8) else {
            throw PlaceIdentifierError.dataEncodingFailed
        }
        
        return encodedData.base64EncodedString()
    }
}

extension PlaceIdentifier {
    enum PlaceIdentifierError: Error, LocalizedError {
        case nameUnavailable
        case nameIsEmpty
        case dataEncodingFailed
        case idDecodingFailed
        case idFormatInvalid
        case coordinateParsingFailed
        
        var errorDescription: String {
            switch self {
            case .nameUnavailable:
                return "The name is unavailable or invalid."
            case .nameIsEmpty:
                return "The name cannot be empty."
            case .dataEncodingFailed:
                return "Failed to encode the data."
            case .idDecodingFailed:
                return "Failed to decode the ID."
            case .idFormatInvalid:
                return "The ID format is invalid."
            case .coordinateParsingFailed:
                return "Failed to parse the coordinates."
            }
        }
    }
}
