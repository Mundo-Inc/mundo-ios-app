//
//  Location.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/10/23.
//

import Foundation
import MapKit

enum DistanceUnit {
    case kilometers
    case miles
}

func distanceBetween(lat1: Double, lon1: Double, lat2: Double, lon2: Double, unit: DistanceUnit = .kilometers) -> Double {
    let location1 = CLLocation(latitude: lat1, longitude: lon1)
    let location2 = CLLocation(latitude: lat2, longitude: lon2)
    
    let distanceInMeters = location1.distance(from: location2)
    
    switch unit {
    case .miles:
        return distanceInMeters * 0.000621371 // Convert meters to miles
    case .kilometers:
        return distanceInMeters * 0.001 // Convert meters to kilometers
    }
}

@MainActor
func distanceFromMe(lat: Double, lng: Double, unit: DistanceUnit = .kilometers) -> Double? {
    let myLocation = LocationManager.shared.location
    let location = CLLocation(latitude: lat, longitude: lng)
    
    if let myLocation {
        let distanceInMeters = myLocation.distance(from: location)
        
        switch unit {
        case .miles:
            return distanceInMeters * 0.000621371 // Convert meters to miles
        case .kilometers:
            return distanceInMeters * 0.001 // Convert meters to kilometers
        }
    } else {
        return nil
    }
}


func getClusterRegion(coordinates: [CLLocationCoordinate2D], expansionRatio: Double = 1.2) -> MKCoordinateRegion? {
    // Ensure there are markers to calculate the region
    guard !coordinates.isEmpty else { return nil }

    let latitudes = coordinates.map { $0.latitude }
    let longitudes = coordinates.map { $0.longitude }

    guard let minLat = latitudes.min(),
          let maxLat = latitudes.max(),
          let minLong = longitudes.min(),
          let maxLong = longitudes.max() else { return nil }

    let centerLat = (minLat + maxLat) / 2
    let centerLong = (minLong + maxLong) / 2
    let spanLat = (maxLat - minLat) * expansionRatio
    let spanLong = (maxLong - minLong) * expansionRatio
    
    return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong))
}
