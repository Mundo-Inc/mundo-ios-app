//
//  ExploreView16.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import SwiftUI
import MapKit
import Kingfisher

@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use ExploreView17 for iOS 17 and above")
struct ExploreView16: View {
    @EnvironmentObject private var exploreSearchVM: ExploreSearchVM
    
    /// for iOS 16
    @StateObject private var vm = ExploreVM16()
    
    func buildAnnotations(from mapItems: [MKMapItem]) -> [MKPointAnnotation] {
        return mapItems.map { mapItem in
            let annotation = MKPointAnnotation()
            annotation.title = mapItem.name
            annotation.coordinate = mapItem.placemark.coordinate
            return annotation
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                Map16(centerCoordinate: $vm.centerCoordinate, annotations: vm.searchResults != nil ? buildAnnotations(from: vm.searchResults!) : [], onTap: { coordinate in
                    Task {
                        let mapItem = await vm.mapClickHandler(coordinate: coordinate)
                        if let mapItem {
                            if let category = mapItem.pointOfInterestCategory {
                                if !SearchDM.AcceptablePointOfInterestCategories.contains(category) {
                                    withAnimation {
                                        vm.selectedPlace = nil
                                    }
                                    return
                                }
                            }
                            withAnimation {
                                vm.selectedPlace = mapItem
                            }
                            await vm.fetchPlace(mapItem: mapItem)
                        } else {
                            withAnimation {
                                vm.selectedPlace = nil
                            }
                        }
                    }
                }, mapRegion: $exploreSearchVM.mapRegion)
                
                if let item = vm.selectedPlace {
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
                                    vm.selectedPlace = nil
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .padding()
                            }
                        }
                        .padding(.leading, 8)
                        
                        NavigationLink(value: vm.selectedPlaceData != nil ? AppRoute.place(id: vm.selectedPlaceData!.id) : item.placemark.title != nil ? AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: item.placemark.coordinate, title: item.placemark.title!)) : nil) {
                            VStack {
                                if let place = vm.selectedPlaceData {
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
                        }
                        .foregroundStyle(.primary)
                    }
                    .background(.thinMaterial)
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(maxHeight: 240)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.bouncy, value: vm.selectedPlace)
                    .zIndex(2)
                }
            }
            
            ZStack {
                if let searchResults = vm.searchResults, !searchResults.isEmpty {
                    Button {
                        withAnimation {
                            vm.searchResults = nil
                        }
                    } label: {
                        Label(
                            title: { Text("Clear search results") },
                            icon: { Image(systemName: "xmark") }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.themePrimary)
                    }
                    .font(.custom(style: .subheadline))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: 6)
                }
                
                ExploreSearchView(exploreSearchVM: exploreSearchVM) { results in
                    vm.setSearchResults(results)
                } panToRegion: { region in
                    vm.panToRegion(region)
                }

            }
        }
        .ignoresSafeArea(.keyboard)
        .toolbarBackground(Color.themePrimary, for: .navigationBar)
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .handleNavigationDestination()
    }
}

fileprivate struct Map16: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    let onTap: (CLLocationCoordinate2D) -> Void
    @Binding var mapRegion: MKCoordinateRegion?
    
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
        Coordinator(self, mapRegion: $mapRegion)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: Map16
        @Binding var mapRegion: MKCoordinateRegion?
        
        init(_ parent: Map16, mapRegion: Binding<MKCoordinateRegion?>) {
            self.parent = parent
            self._mapRegion = mapRegion
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            let coordinate = (gesture.view as! MKMapView).convert(location, toCoordinateFrom: gesture.view)
            parent.onTap(coordinate)
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            mapRegion = mapView.region
        }
    }
}


#Preview {
    ExploreView16()
        .environmentObject(ExploreSearchVM())
}
