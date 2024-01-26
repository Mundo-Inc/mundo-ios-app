//
//  ExploreSearchView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

struct ExploreSearchView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.isSearching) var isSearching
    
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var exploreSearchVM: ExploreSearchVM
    @ObservedObject var mapVM: ExploreVM
    
    var isLocationAvailable: Bool {
        locationManager.location != nil
    }
    
    init(exploreSearchVM: ExploreSearchVM, mapVM: ExploreVM) {
        self._exploreSearchVM = ObservedObject(wrappedValue: exploreSearchVM)
        self._mapVM = ObservedObject(wrappedValue: mapVM)
    }
    
    var body: some View {
        if isSearching {
            ZStack {
                Color.themeBG
                    .ignoresSafeArea()
                
                TabView(selection: $exploreSearchVM.scope) {
                    VStack(spacing: 0) {
                        if !exploreSearchVM.placeSearchResults.isEmpty {
                            Button {
                                dismissSearch()
                                mapVM.searchResults = exploreSearchVM.placeSearchResults
                                
                                if let region = getClusterRegion(coordinates: exploreSearchVM.placeSearchResults.map { $0.placemark.coordinate }) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            mapVM.panToRegion(region: region)
                                        }
                                    }
                                }
                            } label: {
                                Label(
                                    title: { Text("Show results on Map") },
                                    icon: { Image(systemName: "map.fill") }
                                )
                                .font(.custom(style: .headline))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.themePrimary)
                                .clipShape(.rect(cornerRadius: 8))
                            }
                            .padding()
                        }
                        
                        Divider()
                        
                        List(exploreSearchVM.placeSearchResults, id: \.self) { place in
                            PlaceCard(place: place)
                                .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .scrollDismissesKeyboard(.interactively)
                    }
                    .opacity(exploreSearchVM.isLoading ? 0.6 : 1)
                    .tag(SearchScopes.places)
                    
                    List(exploreSearchVM.userSearchResults) { user in
                        UserCard(user: user)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.interactively)
                    .opacity(exploreSearchVM.isLoading ? 0.6 : 1)
                    .tag(SearchScopes.users)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .transition(AnyTransition.opacity.animation(.easeInOut))
        }
    }
}

fileprivate struct PlaceCard: View {
    let place: MKMapItem
    
    var body: some View {
        if let title = place.name {
            NavigationLink(value: AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title))) {
                HStack {
                    Circle()
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 42, height: 42)
                        .overlay {
                            Group {
                                if let pointOfInterestCategory = place.pointOfInterestCategory {
                                    switch pointOfInterestCategory {
                                    case .restaurant:
                                        Image(systemName: "fork.knife.circle.fill")
                                    case .cafe:
                                        Image(systemName: "cup.and.saucer.fill")
                                    case .bakery:
                                        Image(systemName: "storefront.fill")
                                    case .nightlife:
                                        Image(systemName: "mug.fill")
                                    case .winery:
                                        Image(systemName: "wineglass.fill")
                                    default:
                                        Image(systemName: "mappin.circle")
                                    }
                                }
                                else {
                                    Image(systemName: "mappin.circle")
                                }
                            }
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                        }
                    
                    VStack {
                        Text(place.name ?? place.placemark.name ?? "Unknown")
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let distance = distanceFromMe(lat: place.placemark.coordinate.latitude, lng: place.placemark.coordinate.longitude, unit: .miles) {
                            Text(String(format: "%.1f", distance) + " Miles away")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("-")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                }
            }
            .foregroundStyle(.primary)
        }
    }
}

fileprivate struct UserCard: View {
    let user: UserOverview
    
    var body: some View {
        NavigationLink(value: AppRoute.userProfile(userId: user.id)) {
            HStack {
                ProfileImage(user.profileImage, size: 42, cornerRadius: 10)
                
                VStack {
                    if (user.verified) {
                        HStack {
                            Text(user.name)
                                .font(.custom(style: .body))
                                .bold()
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 12))
                                .foregroundStyle(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    } else {
                        Text(user.name)
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("@" + user.username)
                        .font(.custom(style: .caption))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                    
                }
                
                LevelView(level: user.progress.level)
                    .frame(width: 28, height: 28)
            }
        }
        .foregroundStyle(.primary)
    }
}
