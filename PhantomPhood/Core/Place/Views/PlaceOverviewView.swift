//
//  PlaceOverviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/2/23.
//

import SwiftUI
import MapKit

struct PlaceOverviewView: View {
    @ObservedObject var vm: PlaceVM
    @State private var isMapCollapsed = true
    
    // Only used on iOS 16
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        VStack(alignment: .leading) {
            if let place = vm.place {
                Group {
                    if #available(iOS 17.0, *) {
                        Map(initialPosition: .region(.init(center: CLLocationCoordinate2D(latitude: place.location.geoLocation.lat, longitude: place.location.geoLocation.lng), latitudinalMeters: 2000, longitudinalMeters: 2000))) {
                            Marker(place.name, coordinate: CLLocationCoordinate2D(latitude: place.location.geoLocation.lat, longitude: place.location.geoLocation.lng))
                        }
                    } else {
                        Map(
                            coordinateRegion: $mapRegion,
                            annotationItems: [
                                MapLocation(name: place.name, coordinate: CLLocationCoordinate2D(latitude: place.location.geoLocation.lat, longitude: place.location.geoLocation.lng))
                            ],
                            annotationContent: { location in
                                MapMarker(coordinate: location.coordinate)
                            }
                        )
                        .onAppear(perform: {
                            mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.location.geoLocation.lat, longitude: place.location.geoLocation.lng), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        })
                    }
                }
                .frame(height: 170)
                .overlay(alignment: .topLeading) {
                    if let address = place.location.address, isMapCollapsed {
                        VStack(alignment: .leading) {
                            Text("Located in")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(address)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .font(.custom(style: .subheadline))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.all)
                        .background(.black.opacity(0.4))
                        .transition(.offset(y: 400))
                        .onTapGesture {
                            withAnimation {
                                isMapCollapsed = false
                            }
                        }
                    } else if !isMapCollapsed {
                        HStack {
                            Button {
                                withAnimation {
                                    isMapCollapsed = true
                                }
                            } label: {
                                Text("Hide")
                                    .font(.custom(style: .subheadline))
                            }
                            .buttonStyle(.bordered)
                            .padding(.top)
                            .padding(.trailing)
                            .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .clipShape(Rectangle())
            } else {
                Rectangle()
                    .foregroundStyle(Color.themePrimary)
                    .frame(height: 170)
            }
            
            Button {
                if vm.place != nil {
                    vm.isMapNavigationPresented = true
                }
            } label: {
                Label {
                    Text("Get Directions")
                } icon: {
                    Image(systemName: "location.square")
                }
            }
            .controlSize(.large)
            .foregroundStyle(.primary)
            .font(.custom(style: .body))
            .padding(.top, 10)
            .confirmationDialog("Directions", isPresented: $vm.isMapNavigationPresented, titleVisibility: .visible) {
                if let place = vm.place {
                    // Apple maps
                    if let url = URL(string: "http://maps.apple.com/?q=\(place.name)&ll=\(place.location.geoLocation.lat),\(place.location.geoLocation.lng)") {
                        Link("Apple Maps", destination: url)
                    }
                    
                    // Google maps
                    if let url = URL(string: "comgooglemaps://?q=\(place.name)&center=\(place.location.geoLocation.lat),\(place.location.geoLocation.lng)&zoom=14&views=traffic") {
                        Link("Google Maps", destination: url)
                    }
                }
            }
            .padding(.horizontal)
            
            VStack {
                Text("Rating and scores")
                    .font(.custom(style: .headline))
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    HStack {
                        PhantomScoreView(score: vm.place?.scores.phantom, isLoading: vm.place == nil)
                            .frame(height: 70)
                        GoogleRatingView(rating: vm.place?.thirdParty.google?.rating, reviewCount: vm.place?.thirdParty.google?.reviewCount, isLoading: vm.place == nil)
                            .frame(height: 70)
                    }
                    HStack {
                        YelpRatingView(rating: vm.place?.thirdParty.yelp?.rating, reviewCount: vm.place?.thirdParty.yelp?.reviewCount, isLoading: vm.place == nil)
                            .frame(height: 70)
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                
            }
            .padding()
        }
        
    }
}

#Preview {
    PlaceOverviewView(vm: PlaceVM(id: "645c1d1ab41f8e12a0d166bc"))
}
