//
//  SearchView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/11/23.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
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
        dismiss()
        searchViewModel.showSearch = false
        searchViewModel.tokens.removeAll()
        searchViewModel.text = ""
    }
    
    @FocusState var textFocused
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 30, height: 3)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                    
                    HStack(spacing: -14) {
                        ForEach(searchViewModel.tokens) { token in
                            Label(
                                title: {
                                    switch token {
                                    case .checkin: Text(SearchTokens.checkin.rawValue)
                                    case .addReview: Text(SearchTokens.addReview.rawValue)
                                    }
                                },
                                icon: { Image(systemName: "xmark") }
                            )
                            .animation(.spring, value: searchViewModel.tokens.isEmpty)
                            .transition(.push(from: .trailing))
                            .font(.custom(style: .caption))
                            .bold()
                            .foregroundStyle(Color.accentColor)
                            .padding(.vertical, 10.9)
                            .padding(.horizontal, 5)
                            .background(Color.themePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .zIndex(10)
                            .shadow(radius: 10)
                            .onTapGesture {
                                withAnimation {
                                    searchViewModel.tokens.removeAll()
                                }
                            }
                        }
                                              
                        ZStack {
                            TextField("Search", text: $searchViewModel.text)
                                .withFilledStyle(size: .small, paddingLeading: searchViewModel.tokens.isEmpty ? 34 : 20)
                                .textInputAutocapitalization(.never)
                                .animation(.spring, value: searchViewModel.tokens.isEmpty)
                                .focused($textFocused)
                            
                            if searchViewModel.tokens.isEmpty {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14))
                                    .padding(.leading, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                    .transition(.push(from: .leading))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        textFocused = true
                    }
                    
                    Picker("Scope", selection: $searchViewModel.scope) {
                        Text("Places")
                            .tag(SearchScopes.places)
                        
                        Text("Users")
                            .tag(SearchScopes.users)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    Group {
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
                                                    .padding(.top)
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
                                                    .padding(.top)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .scrollDismissesKeyboard(.interactively)
                                    .tag(SearchScopes.users)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
                                                .padding(.top)
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
                                                .padding(.top)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .scrollDismissesKeyboard(.interactively)
                                .tag(SearchScopes.users)
                            }
                        }
                    }
                    .opacity(searchViewModel.isLoading ? 0.6 : 1)
                }
            }
//            .toolbar(content: {
//                ToolbarItem(placement: .principal) {
//                    TextField("Search", text: $searchViewModel.text)
//                        .withFilledStyle(size: .small)
//                        .frame(width: UIScreen.main.bounds.width - 30)
//                }
//                
//            })
//            .searchable(text: $searchViewModel.text, tokens: $searchViewModel.tokens, placement: .navigationBarDrawer(displayMode: .always), token: { token in
//                switch token {
//                case .checkin: Text(SearchTokens.checkin.rawValue)
//                case .addReview: Text(SearchTokens.addReview.rawValue)
//                }
//            })
//            .searchScopes($searchViewModel.scope, activation: .onSearchPresentation, {
//                if onPlaceSelect != nil && onUserSelect != nil {
//                    if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
//                        ForEach(SearchScopes.allCases) { scope in
//                            Text(scope.rawValue)
//                                .tag(scope)
//                        }
//                    }
//                }
//            })
//            .navigationTitle("Search")
//            .navigationBarTitleDisplayMode(.inline)
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
                if !user.profileImage.isEmpty, let url = URL(string: user.profileImage) {
                    KFImage.url(url)
                        .placeholder {
                            Circle()
                                .foregroundStyle(Color.themePrimary)
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
                
                LevelView(level: user.progress.level)
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
