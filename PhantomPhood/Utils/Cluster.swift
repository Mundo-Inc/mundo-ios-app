//
//  Cluster.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/13/23.
//

import Foundation
import MapKit

final class Cluster {
    struct MapRegionCluster<T: CoordinateRepresentable> {
        let clustered: [MapRegionClusterData<T>]
        let solo: [T]
    }
    struct MapRegionClusterData<T: CoordinateRepresentable>: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let count: Int
        let content: [T]
    }
    static func getMapRegionCluster<T: CoordinateRepresentable>(region: MKCoordinateRegion, items: [T]) -> MapRegionCluster<T> {
        // Calculate grid size dynamically based on the region size
        let latGridSize = region.span.latitudeDelta / 5.0 // adjust divisor for finer or coarser grid
        let lonGridSize = region.span.longitudeDelta / 5.0
        
        func gridKey(for item: T) -> String {
            let lat = Int(item.latitude / latGridSize)
            let lng = Int(item.longitude / lonGridSize)
            return "\(lat)_\(lng)"
        }
        
        var clusters = [String: [T]]()
        var soloItems = [T]()
        
        for item in items {
            let key = gridKey(for: item)
            clusters[key, default: []].append(item)
        }
        
        var clusteredData = [MapRegionClusterData<T>]()
        for (_, content) in clusters {
            if content.count == 1 {
                soloItems.append(contentsOf: content)
            } else {
                let avgLat = content.reduce(0, {$0 + $1.latitude}) / Double(content.count)
                let avgLon = content.reduce(0, {$0 + $1.longitude}) / Double(content.count)
                let centerCoord = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
                if let first = content.first {
                    let key = gridKey(for: first)
                    clusteredData.append(MapRegionClusterData(id: key, coordinate: centerCoord, count: content.count, content: content))
                } else {
                    clusteredData.append(MapRegionClusterData(id: UUID().uuidString, coordinate: centerCoord, count: content.count, content: content))
                }
            }
        }
        
        return .init(clustered: clusteredData, solo: soloItems)
    }
}
