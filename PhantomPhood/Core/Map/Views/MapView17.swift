//
//  MapView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/13/23.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView17: View {
    @ObservedObject var vm: MapViewModel
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            ForEach(vm.places) { place in
                Annotation(
                    place.name,
                    coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                ) {
                    MapPlaceMarker(place: place)
                }

            }
            
            UserAnnotation()
        }
        .onMapCameraChange { context in
            Task {
                await vm.fetchRegionPlaces(region: context.region)
            }
        }
        .mapControlVisibility(.visible)
        .mapControls {
            MapUserLocationButton()
        }
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        return MapView17(vm: MapViewModel())
    } else {
        return Text("Only iOS 17 and above")
    }
}
