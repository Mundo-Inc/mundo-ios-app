//
//  MapView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject private var vm = MapViewModel()
    @Environment(\.dismissSearch) var dismissSearch
    
    @StateObject var searchViewModel = SearchViewModel()
    
    func showPlace(place: CompactPlace) {
        
    }
    
    func showUser(user: User) {
        
    }
    
    var body: some View {
        NavigationStack(path: $appData.mapNavStack) {
            ZStack {
                if #available(iOS 17.0, *) {
                    MapView17(vm: vm)
                } else {
                    MapView16(vm: vm)
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
                            appData.mapNavStack.append(MapStack.place(id: place.id, action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                        } onUserSelect: { user in
                            appData.mapNavStack.append(MapStack.userProfile(id: user.id))
                        }
                    }
                }
            })
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MapStack.self) { link in
                switch link {
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
        .environmentObject(searchViewModel)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AppData())
    }
}
