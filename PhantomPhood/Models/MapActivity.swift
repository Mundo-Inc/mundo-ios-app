//
//  MapActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/12/23.
//

import Foundation
import CoreLocation
import MapKit

struct MapActivity: Decodable, Identifiable {
    let placeId: String
    let coordinates: [Double]
    let activities: Activities
    
    var location: CLLocation {
        .init(latitude: self.coordinates.last ?? 0, longitude: self.coordinates.first ?? 0)
    }

    var id: String {
        self.placeId
    }
    
    struct Activities: Decodable {
        let reviewCount: Int
        let checkinCount: Int
        let data: [ActivitiesData]
    }
    
    struct ActivitiesData: Decodable {
        let name: String
        let profileImage: URL?
        let checkinsCount: Int
        let reviewsCount: Int
    }
}

struct MapActivityClusters {
    let clustered: [MapRegionClusterData]
    let solo: [MapActivity]
    
    struct MapRegionClusterData: Identifiable {
        let id: String
        let location: CLLocation
        var radius: CLLocationDistance
        var count: Int
        var content: [MapActivity]
    }
}

extension MapActivityClusters {
    init(region: MKCoordinateRegion, items: [MapActivity]) {
        let latGridSize = region.span.latitudeDelta / 5.0 // adjust divisor for finer or coarser grid
        let lonGridSize = region.span.longitudeDelta / 5.0
        
        func gridKey(for item: MapActivity) -> String {
            let lat = Int(item.location.coordinate.latitude / latGridSize)
            let lng = Int(item.location.coordinate.longitude / lonGridSize)
            return "\(lat)_\(lng)"
        }
        
        var clusters = [String: [MapActivity]]()
        var soloItems = [MapActivity]()
        
        for item in items {
            let key = gridKey(for: item)
            clusters[key, default: []].append(item)
        }
        
        var clusteredData = [MapRegionClusterData]()
        for (_, content) in clusters {
            if content.count == 1 {
                soloItems.append(contentsOf: content)
            } else {
                let avgLat = content.reduce(0, {$0 + $1.location.coordinate.latitude}) / Double(content.count)
                let avgLon = content.reduce(0, {$0 + $1.location.coordinate.longitude}) / Double(content.count)
                let centerCoord = CLLocation(latitude: avgLat, longitude: avgLon)
                let maxDistance = content.max(by: { centerCoord.distance(from: $0.location) < centerCoord.distance(from: $1.location) })?.location.distance(from: centerCoord) ?? 0
                
                if let first = content.first {
                    let key = gridKey(for: first)
                    clusteredData.append(MapRegionClusterData(id: key, location: centerCoord, radius: maxDistance, count: content.count, content: content))
                } else {
                    clusteredData.append(MapRegionClusterData(id: UUID().uuidString, location: centerCoord, radius: maxDistance, count: content.count, content: content))
                }
            }
        }
        
        self.clustered = clusteredData
        self.solo = soloItems
    }

}
