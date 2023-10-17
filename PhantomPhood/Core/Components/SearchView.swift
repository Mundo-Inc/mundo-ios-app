//
//  SearchView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/11/23.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.isSearching) var isSearching
    @ObservedObject var locationManager = LocationManager.shared
    
    @ObservedObject var searchViewModel: SearchViewModel
    
    var isLocationAvailable: Bool {
        locationManager.location != nil
    }
    
    var onPlaceSelect: ((CompactPlace) -> Void)? = nil
    var onUserSelect: ((User) -> Void)? = nil
    
    init(vm: SearchViewModel, onPlaceSelect: ((CompactPlace) -> Void)? = nil, onUserSelect: ((User) -> Void)? = nil) {
        self._searchViewModel = ObservedObject(wrappedValue: vm)
        self.onPlaceSelect = onPlaceSelect
        self.onUserSelect = onUserSelect
    }
        
    func closeSearch() {
        dismissSearch()
        searchViewModel.showSearch = false
        searchViewModel.tokens.removeAll()
        searchViewModel.text = ""
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let onPlaceSelect, let onUserSelect {
                    TabView(selection: $searchViewModel.scope) {
                        VStack {
                            HStack {
                                Text("Region")
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        switch searchViewModel.searchPlaceRegion {
                                        case .nearMe:
                                            searchViewModel.searchPlaceRegion = .global
                                        case .global:
                                            searchViewModel.searchPlaceRegion = .nearMe
                                        }
                                    }
                                } label: {
                                    Label {
                                        Text(searchViewModel.searchPlaceRegion.title)
                                    } icon: {
                                        Image(systemName: searchViewModel.searchPlaceRegion.icon)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .font(.custom(style: .body))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.themePrimary.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 4))
                            .padding(.horizontal)
                            
                            Divider()
                            
                            ScrollView {
                                VStack {
                                    ForEach(searchViewModel.placeSearchResults) { place in
                                        PlaceCard(searchViewModel: searchViewModel, place: place, closeSearch: closeSearch, onSelect: onPlaceSelect)
                                        Divider()
                                    }
                                    if searchViewModel.isLoading {
                                        ProgressView()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .scrollDismissesKeyboard(.interactively)
                        }
                        
                        .tag(SearchScopes.places)
                        
                        if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
                            ScrollView {
                                VStack {
                                    ForEach(searchViewModel.userSearchResults) { user in
                                        UserCard(user: user, closeSearch: closeSearch, onSelect: onUserSelect)
                                        Divider()
                                    }
                                    if searchViewModel.isLoading {
                                        ProgressView()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .scrollDismissesKeyboard(.interactively)
                            .tag(SearchScopes.users)
                        }
                    }
                } else if let onPlaceSelect {
                    VStack {
                        HStack {
                            Text("Region")
                            
                            Spacer()
                            
                            Label {
                                Text(isLocationAvailable ? "Near you" : "Global")
                            } icon: {
                                Image(systemName: isLocationAvailable ? "location.fill" : "globe")
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .font(.custom(style: .body))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.themePrimary.opacity(0.5))
                        .clipShape(.rect(cornerRadius: 4))
                        .padding(.horizontal)
                        
                        Divider()
                        
                        ScrollView {
                            VStack {
                                ForEach(searchViewModel.placeSearchResults) { place in
                                    PlaceCard(searchViewModel: searchViewModel, place: place, closeSearch: closeSearch, onSelect: onPlaceSelect)
                                    Divider()
                                }
                                if searchViewModel.isLoading {
                                    ProgressView()
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                } else if let onUserSelect {
                    if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
                        ScrollView {
                            VStack {
                                ForEach(searchViewModel.userSearchResults) { user in
                                    UserCard(user: user, closeSearch: closeSearch, onSelect: onUserSelect)
                                    Divider()
                                }
                                if searchViewModel.isLoading {
                                    ProgressView()
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .tag(SearchScopes.users)
                    }
                }
            }
            .searchable(text: $searchViewModel.text, tokens: $searchViewModel.tokens, placement: .navigationBarDrawer(displayMode: .always), token: { token in
                switch token {
                case .checkin: Text(SearchTokens.checkin.rawValue)
                case .addReview: Text(SearchTokens.addReview.rawValue)
                }
            })
            .searchScopes($searchViewModel.scope, activation: .onSearchPresentation, {
                if onPlaceSelect != nil && onUserSelect != nil {
                    if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
                        ForEach(SearchScopes.allCases) { scope in
                            Text(scope.rawValue)
                                .tag(scope)
                        }
                    }
                }
            })
            .onSubmit(of: .search) {
                print(searchViewModel.text)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .opacity(searchViewModel.isLoading ? 0.6 : 1)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(Color.themeBG)
            
        }
    }
}

fileprivate struct PlaceCard: View {
    @ObservedObject var searchViewModel: SearchViewModel

    let place: CompactPlace
    
    let closeSearch: () -> Void
    let onSelect: (CompactPlace) -> Void
        
    var body: some View {
        Button {
            self.onSelect(place)
            closeSearch()
        } label: {
            HStack {
                Circle()
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 42, height: 42)
                    .overlay {
                        Group {
                            if let amenity = place.amenity {
                                Image(systemName: amenity.image)
                            } else {
                                Image(systemName: "mappin.circle")
                            }
                        }
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    }
                
                VStack {
                    Text(place.name)
                        .font(.custom(style: .body))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let distance = distanceFromMe(lat: place.location.geoLocation.lat, lng: place.location.geoLocation.lng, unit: .miles) {
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

fileprivate struct UserCard: View {
    let user: User
    
    let closeSearch: () -> Void
    let onSelect: (User) -> Void
    
    var body: some View {
        Button {
            self.onSelect(user)
            closeSearch()
        } label: {
            HStack {
                if let pImage = user.profileImage, let url = URL(string: pImage) {
                    CacheAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .overlay {
                                    ProgressView()
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Circle()
                                .overlay {
                                    Image(systemName: "xmark.icloud.fill")
                                }
                        }
                    }
                    .contentShape(Circle())
                    .clipShape(Circle())
                    .frame(width: 42, height: 42)
                }
                
                VStack {
                        Text(user.name)
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("@" + user.username)
                        .font(.custom(style: .caption))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                    
                }
                
                LevelView(level: .convert(level: user.level))
                    .frame(width: 28, height: 28)

            }
        }
        .foregroundStyle(.primary)
    }
}


#Preview {
    SearchView(vm: SearchViewModel()) { place in
        print("Place")
    } onUserSelect: { user in
        print("User")
    }
}
