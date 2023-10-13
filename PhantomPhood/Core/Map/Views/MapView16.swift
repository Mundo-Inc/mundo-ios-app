//
//  MapView16.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/13/23.
//

import SwiftUI
import MapKit

struct MapView16: View {
    private let locationManager = LocationManager.shared
    @ObservedObject var vm: MapViewModel
    @State var coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(center: .init(latitude: 40.7250, longitude: -74.002), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    init(vm: MapViewModel) {
        self._vm = ObservedObject(wrappedValue: vm)
        if let location = locationManager.location {
            self._coordinateRegion = State(wrappedValue: MKCoordinateRegion(center: .init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    }
    
    struct EquatableRegion: Equatable {
        var center: CLLocationCoordinate2D
        var span: MKCoordinateSpan

        static func ==(lhs: EquatableRegion, rhs: EquatableRegion) -> Bool {
            return lhs.center.latitude == rhs.center.latitude &&
                   lhs.center.longitude == rhs.center.longitude &&
                   lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
                   lhs.span.longitudeDelta == rhs.span.longitudeDelta
        }
    }
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion, showsUserLocation: true, annotationItems: vm.places) { place in
            MapAnnotation(coordinate: .init(latitude: place.latitude, longitude: place.longitude)) {
                MapPlaceMarker(place: place)
            }
        }
        .onChange(of: EquatableRegion(center: coordinateRegion.center, span: coordinateRegion.span)) { value in
                if !vm.isLoading {
                    vm.debouncedFetchRegionPlaces(region: coordinateRegion)
                }
            }
            
//        Map(position: $position) {
//            ForEach(vm.places) { place in
//                Annotation(
//                    place.name,
//                    coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
//                ) {
//                    MapPlaceMarker(place: place)
//                }
//
//            }
//            
//            UserAnnotation()
//        }
//        .onMapCameraChange { context in
//            Task {
//                await vm.fetchRegionPlaces(region: context.region)
//            }
//        }
//        .mapControlVisibility(.visible)
//        .mapControls {
//            MapUserLocationButton()
//        }
    }
}

#Preview {
    MapView16(vm: MapViewModel())
}
