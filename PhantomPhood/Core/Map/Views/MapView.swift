//
//  MapView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject private var appData = AppData.shared
    
    @Environment(\.dismissSearch) var dismissSearch
    
    @StateObject private var vm = MapViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack(path: $appData.mapNavStack) {
            ZStack(alignment: .top) {
                if #available(iOS 17.0, *) {
                    MapView17(mapVM: vm)
                } else {
                    MapView16(mapVM: vm)
                }
                
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
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        searchViewModel.showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
                        searchViewModel.tokens.removeAll()
                        searchViewModel.text = ""
                        dismissSearch()
                    }) {
                        SearchView(vm: searchViewModel) { place in
                            if let title = place.name {
                                appData.mapNavStack.append(MapStack.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                            }
                        } onUserSelect: { user in
                            appData.mapNavStack.append(MapStack.userProfile(userId: user.id))
                        } header: {
                            if !searchViewModel.placeSearchResults.isEmpty {
                                Button {
                                    searchViewModel.showSearch = false
                                    withAnimation {
                                        vm.searchResults = searchViewModel.placeSearchResults
                                    }
                                } label: {
                                    HStack {
                                        Label(
                                            title: { Text("Show results on Map") },
                                            icon: { Image(systemName: "map.fill") }
                                        )
                                    }
                                    .font(.custom(style: .headline))
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.themePrimary)
                                    .clipShape(Capsule())
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            })
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MapStack.self) { link in
                switch link {
                case .placeMapPlace(let mapPlace, let action):
                    PlaceView(mapPlace: mapPlace, action: action)
                    
                    // Common
                    
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .userProfile(let id):
                    UserProfileView(id: id)
                case .userConnections(let userId, let initTab):
                    UserConnectionsView(userId: userId, activeTab: initTab)
                case .userActivities(let userId, let activityType):
                    ProfileActivitiesView(userId: userId, activityType: activityType)
                case .userCheckins(let userId):
                    ProfileCheckins(userId: userId)
                }
            }
        }
        .environmentObject(searchViewModel)
    }
}

#Preview {
    MapView()
}
