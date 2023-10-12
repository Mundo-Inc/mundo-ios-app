//
//  Location.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/10/23.
//

import Foundation
import CoreLocation

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

