//
//  MapKit.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/10/23.
//

import Foundation
import MapKit
import SwiftUI

extension MKPointOfInterestCategory {
    var image: Image {
        switch self {
        case .restaurant:
            Image(.Icons.restaurant)
        case .cafe:
            Image(.Icons.cafe)
        case .bakery:
            Image(.Icons.bakery)
        case .nightlife:
            Image(.Icons.nightLife)
        case .winery:
            Image(.Icons.winery)
        case .fitnessCenter:
            Image(.Icons.gym)
        case .beach:
            Image(.Icons.beach)
        default:
            Image(systemName: "mappin.circle")
        }
    }
}

extension MKCoordinateRegion {
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let northEastCorner = CLLocationCoordinate2D(latitude: center.latitude + (span.latitudeDelta / 2.0), longitude: center.longitude + (span.longitudeDelta / 2.0))
        let southWestCorner = CLLocationCoordinate2D(latitude: center.latitude - (span.latitudeDelta / 2.0), longitude: center.longitude - (span.longitudeDelta / 2.0))
        
        return coordinate.latitude >= southWestCorner.latitude &&
        coordinate.latitude <= northEastCorner.latitude &&
        coordinate.longitude >= southWestCorner.longitude &&
        coordinate.longitude <= northEastCorner.longitude
    }

    /// Returns northEast and southWest coordinates from MKCoordinateRegion
    var boundariesNESW: (NE: CLLocationCoordinate2D, SW: CLLocationCoordinate2D) {
        let center = self.center
        let halfLatDelta = self.span.latitudeDelta / 2.0
        let halfLonDelta = self.span.longitudeDelta / 2.0

        let northEast = CLLocationCoordinate2D(latitude: center.latitude + halfLatDelta, longitude: center.longitude + halfLonDelta)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - halfLatDelta, longitude: center.longitude - halfLonDelta)

        return (northEast, southWest)
    }

    /// shifts center by given x and y percentage
    func shiftCenter(yPercentage: CGFloat = 0, xPercentage: CGFloat = 0) -> MKCoordinateRegion {
        let center = self.center
        let halfLatDelta = self.span.latitudeDelta / 2.0
        let halfLonDelta = self.span.longitudeDelta / 2.0

        let newCenter = CLLocationCoordinate2D(latitude: center.latitude + halfLatDelta * Double(yPercentage), longitude: center.longitude + halfLonDelta * Double(xPercentage))
        
        return MKCoordinateRegion(center: newCenter, span: self.span)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    /// Calculates the distance (in meters) to another CLLocationCoordinate2D.
    /// - Parameter coordinate: The target coordinate to measure the distance to.
    /// - Returns: The distance in meters as a Double.
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let endLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return startLocation.distance(from: endLocation)
    }
}

@available(iOS 17.0, *)
extension MapCameraUpdateContext {
    var scaleValue: CGFloat {
        let value = 1.0 / (self.region.span.latitudeDelta * 8)
        return max(0.4, min(value, 1))
    }
}
