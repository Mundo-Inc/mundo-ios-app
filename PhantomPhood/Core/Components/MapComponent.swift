//
//  MapComponent.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

/// marker prototype
/// It should contain coordinates, title, and optionally a link with type of AppRoute
struct CustomMapMarkerType: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let image: Image?
    let link: AppRoute?
    let onMarkerTap: (() -> Void)?
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: Image? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
        self.link = nil
        self.onMarkerTap = nil
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: Image? = nil, link: AppRoute? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
        self.link = link
        self.onMarkerTap = nil
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: Image? = nil, onMarkerTap: (() -> Void)? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
        self.onMarkerTap = onMarkerTap
        self.link = nil
    }
}

struct MapComponent: View {
    let markers: [CustomMapMarkerType]

    var body: some View {
        if #available(iOS 17.0, *) {
            Map17(markers: markers)
        } else {
            Map16(markers: markers)
        }
    }
}

@available(iOS 17.0, *)
fileprivate struct Map17: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var markerScale: CGFloat = 1

    let markers: [CustomMapMarkerType]
    
    init(markers: [CustomMapMarkerType]) {
        self.markers = markers
    }

    var body: some View {
        Map(position: $position) {
            ForEach(markers) { marker in
                Annotation(marker.title, coordinate: marker.coordinate) {
                    if let link = marker.link {
                        NavigationLink(value: link) {
                            CustomMapMarker(image: marker.image)
                                .scaleEffect(markerScale)
                        }
                    } else if let onTap = marker.onMarkerTap {
                        CustomMapMarker(image: marker.image)
                            .scaleEffect(markerScale)
                            .onTapGesture(perform: onTap)
                    } else {
                        CustomMapMarker(image: marker.image)
                            .scaleEffect(markerScale)
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
            let scaleValue = 1.0 / mapCameraUpdateContext.region.span.latitudeDelta
            markerScale = scaleValue > 1 ? 1 : scaleValue < 0.4 ? 0.4 : scaleValue
        })
    }
}

fileprivate struct Map16: View {
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var markerScale: CGFloat = 1
    
    let markers: [CustomMapMarkerType]
    
    init(markers: [CustomMapMarkerType]) {
        self.markers = markers
    }
    
    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            annotationItems: markers,
            annotationContent: { marker in
                MapAnnotation(coordinate: marker.coordinate) {
                    if let link = marker.link {
                        NavigationLink(value: link) {
                            CustomMapMarker(image: marker.image)
                                .scaleEffect(markerScale)
                        }
                    } else if let onTap = marker.onMarkerTap {
                        CustomMapMarker(image: marker.image)
                            .scaleEffect(markerScale)
                            .onTapGesture(perform: onTap)
                    } else {
                        CustomMapMarker(image: marker.image)
                            .scaleEffect(markerScale)
                    }
                }
            }
        )
        .onAppear {
            if let region = getClusterRegion(coordinates: markers.map { $0.coordinate }) {
                withAnimation {
                    mapRegion = region
                }
            }
        }
        .onChange(of: mapRegion.span.latitudeDelta) { value in
            let scaleValue = 1.0 / value
            markerScale = scaleValue > 1 ? 1 : scaleValue < 0.4 ? 0.4 : scaleValue
        }
    }
}

#Preview {
    MapComponent(markers: [
        // Eiffel Tower
        CustomMapMarkerType(coordinate: CLLocationCoordinate2D(latitude: 48.858093, longitude: 2.294694), title: "Eiffel Tower", image: Image(systemName: "mappin.and.ellipse")),
        // Big Ben
        CustomMapMarkerType(coordinate: CLLocationCoordinate2D(latitude: 51.50072919999999, longitude: -0.1246254), title: "Big Ben", image: Image(systemName: "mappin.and.ellipse")),
        // Tower Bridge
        CustomMapMarkerType(coordinate: CLLocationCoordinate2D(latitude: 51.5054564, longitude: -0.0753563), title: "Tower Bridge", image: Image(systemName: "mappin.and.ellipse")),
        // London Eye
        CustomMapMarkerType(coordinate: CLLocationCoordinate2D(latitude: 51.503324, longitude: -0.119543), title: "London Eye", image: Image(systemName: "mappin.and.ellipse")),
    ])
}
