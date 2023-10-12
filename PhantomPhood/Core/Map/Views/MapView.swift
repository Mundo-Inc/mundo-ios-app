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
                Map(position: $vm.position) {
                    ForEach(vm.places) { place in
                        Annotation(
                            "Diller Civic Center Playground",
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
            })
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
