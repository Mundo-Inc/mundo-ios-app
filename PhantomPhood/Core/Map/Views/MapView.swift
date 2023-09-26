//
//  MapView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject private var vm = MapViewModel()
    
    var body: some View {
        NavigationStack(path: $appData.mapNavStack) {
            ZStack {
                Map()
                Map(position: $vm.position) {
                    Marker(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)) {
                        Label("San Francisco City Hall", systemImage: "car")
                    }
                    .tint(Color.accentColor)
                    
                    
                    Annotation(
                        "Diller Civic Center Playground",
                        coordinate: CLLocationCoordinate2D(latitude: 41.7128, longitude: -74.0060)
                    ) {
                        MapMarker(type: .restaurant)
                    }
                    
                    Annotation(
                        "GWAf fawg",
                        coordinate: CLLocationCoordinate2D(latitude: 41.7128, longitude: -74.0260)
                    ) {
                        MapMarker(type: .cafe)
                    }
                    
                    Annotation(
                        "Test 41 afwf",
                        coordinate: CLLocationCoordinate2D(latitude: 41.7218, longitude: -74.0060)
                    ) {
                        MapMarker(type: .bar)
                    }
                    
                    Annotation(
                        "Test 41 afwf",
                        coordinate: CLLocationCoordinate2D(latitude: 41.7138, longitude: -74.0180)
                    ) {
                        MapMarker(type: .cluster(count: 24))
                    }
                }
                .mapControlVisibility(.visible)
                .mapControls {
                    MapUserLocationButton()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MapStack.self) { link in
                switch link {
                case .place(let id):
                    PlaceView(id: id)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            MapView()
                .environmentObject(AppData())
        }
    }
}
