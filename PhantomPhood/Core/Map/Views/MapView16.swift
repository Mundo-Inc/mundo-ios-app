//
//  MapView16.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/13/23.
//

import SwiftUI
import MapKit
import Kingfisher

let AcceptablePointOfInterestCategories: [MKPointOfInterestCategory] = [.cafe, .restaurant, .nightlife, .bakery, .brewery, .winery]

struct MapView16: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var locationManager = LocationManager.shared
    
    @ObservedObject var mapVM: MapViewModel
    @State var selectedPlace: MKMapItem? = nil
    @State private var centerCoordinate = CLLocationCoordinate2D()
    //    @State var coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(center: .init(latitude: 40.7250, longitude: -74.002), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @MainActor
    init(mapVM: MapViewModel) {
        self._mapVM = ObservedObject(wrappedValue: mapVM)
        if let location = locationManager.location {
            self._centerCoordinate = State(wrappedValue: location.coordinate)
            //            self._coordinateRegion = State(wrappedValue: MKCoordinateRegion(center: .init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    }
    
    func buildAnnotations(from mapItems: [MKMapItem]) -> [MKPointAnnotation] {
        return mapItems.map { mapItem in
            let annotation = MKPointAnnotation()
            annotation.title = mapItem.name
            annotation.coordinate = mapItem.placemark.coordinate
            return annotation
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map16(centerCoordinate: $centerCoordinate, annotations: mapVM.searchResults != nil ? buildAnnotations(from: mapVM.searchResults!) : [], onTap: { coordinate in
                Task {
                    let mapItem = await mapVM.mapClickHandler(coordinate: coordinate)
                    if let mapItem {
                        if let category = mapItem.pointOfInterestCategory {
                            if !AcceptablePointOfInterestCategories.contains(category) {
                                withAnimation {
                                    self.selectedPlace = nil
                                }
                                return
                            }
                        }
                        withAnimation {
                            self.selectedPlace = mapItem
                        }
                        await mapVM.fetchPlace(mapItem: mapItem)
                    } else {
                        withAnimation {
                            self.selectedPlace = nil
                        }
                    }
                }
            })
            
            if let item = self.selectedPlace {
                VStack {
                    HStack {
                        HStack {
                            if let imageCategory = item.pointOfInterestCategory {
                                imageCategory.image
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.secondary)
                                    .frame(height: 32)
                            }
                            
                            VStack {
                                Text(item.name ?? "Unknown")
                                    .lineLimit(1)
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top)
                                
                                Group {
                                    if let distance = distanceFromMe(lat: item.placemark.coordinate.latitude, lng: item.placemark.coordinate.longitude, unit: .miles) {
                                        Text("\(String(format: "%.1f", distance)) Miles away")
                                    } else {
                                        Text("- Miles away")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .caption))
                            }
                            
                        }
                        
                        Button {
                            withAnimation {
                                self.selectedPlace = nil
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .padding()
                        }
                    }
                    .padding(.leading, 8)
                    
                    VStack {
                        if let place = mapVM.selectedPlaceData {
                            HStack {
                                Text("\(place.reviewCount) Reviews")
                                
                                if let phantomScore = place.scores.phantom {
                                    Divider()
                                        .frame(maxHeight: 10)
                                    Text("👻 \(String(format: "%.0f", phantomScore))")
                                }
                                
                                if let priceRange = place.priceRange {
                                    Divider()
                                        .frame(maxHeight: 10)
                                    Text(String(repeating: "$", count: priceRange))
                                }
                            }
                            .font(.custom(style: .body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if !place.media.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(place.media) { media in
                                            if let url = URL(string: media.src) {
                                                KFImage.url(url)
                                                    .placeholder {
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .frame(width: 90, height: 120)
                                                            .foregroundStyle(Color.themePrimary.opacity(0.4))
                                                            .overlay {
                                                                ProgressView()
                                                            }
                                                    }
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .fade(duration: 0.25)
                                                    .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .contentShape(RoundedRectangle(cornerRadius: 15))
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .frame(width: 90, height: 120)
                                            }
                                        }
                                    }
                                }
                                .scrollIndicators(.hidden)
                            } else {
                                if let thumbnail = place.thumbnail, let url = URL(string: thumbnail) {
                                    KFImage.url(url)
                                        .placeholder {
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 120)
                                                .foregroundStyle(Color.themePrimary.opacity(0.4))
                                                .overlay {
                                                    ProgressView()
                                                }
                                        }
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 120)
                                        .contentShape(RoundedRectangle(cornerRadius: 15))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    Text("No images found")
                                }
                            }
                        } else {
                            HStack {
                                Text("... Reviews")
                                Divider()
                                    .frame(maxHeight: 10)
                                Text("Score")
                                Divider()
                                    .frame(maxHeight: 10)
                                Text("Price")
                            }
                            .font(.custom(style: .body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .redacted(reason: .placeholder)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 90, height: 120)
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 90, height: 120)
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 90, height: 120)
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 90, height: 120)
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 90, height: 120)
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                        
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .onTapGesture {
                        if let place = mapVM.selectedPlaceData {
                            appData.mapNavStack.append(.place(id: place.id))
                        } else {
                            if let title = item.placemark.title {
                                appData.mapNavStack.append(.placeMapPlace(mapPlace: MapPlace(coordinate: item.placemark.coordinate, title: title)))
                            }
                        }
                    }
                }
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 15))
                .frame(maxHeight: 240)
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.bouncy, value: selectedPlace)
                .zIndex(2)
            }
        }
    }
}

struct Map16: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    let onTap: (CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove all existing annotations
        uiView.removeAnnotations(uiView.annotations)
        
        // Add new annotations
        uiView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: Map16
        
        init(_ parent: Map16) {
            self.parent = parent
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            let coordinate = (gesture.view as! MKMapView).convert(location, toCoordinateFrom: gesture.view)
            parent.onTap(coordinate)
        }
    }
}


#Preview {
    MapView16(mapVM: MapViewModel())
}
