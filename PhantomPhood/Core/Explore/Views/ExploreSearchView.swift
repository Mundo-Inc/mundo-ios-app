//
//  ExploreSearchView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

struct ExploreSearchView: View {
    @Binding private var isSearching: Bool
    @Binding private var searchResults: [MKMapItem]?
    
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var exploreSearchVM: ExploreSearchVM
    
    private var isLocationAvailable: Bool {
        locationManager.location != nil
    }
    
    private let panToRegion: (MKCoordinateRegion) -> Void
    
    init(exploreSearchVM: ExploreSearchVM, isSearching: Binding<Bool>, searchResults: Binding<[MKMapItem]?>, panToRegion: @escaping (MKCoordinateRegion) -> Void) {
        self._exploreSearchVM = ObservedObject(wrappedValue: exploreSearchVM)
        self.panToRegion = panToRegion
        self._isSearching = isSearching
        self._searchResults = searchResults
    }
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            self.isSearching.toggle()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundStyle(isSearching ? Color.accentColor : Color.primary)
                            .frame(width: 60, height: 60)
                    }
                    
                    if isSearching || searchResults != nil {
                        Divider()
                            .frame(maxHeight: 36)
                            .padding(.trailing, 10)
                            .foregroundStyle(Color.accentColor)
                        
                        TextField("Search", text: $exploreSearchVM.text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .font(.custom(style: .title2))
                            .keyboardType(.default)
                            .textContentType(UITextContentType.location)
                            .focused($isFocused)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.primary)
                            .onChange(of: exploreSearchVM.text) { value in
                                if !value.isEmpty && !isSearching {
                                    withAnimation {
                                        isSearching = true
                                    }
                                }
                            }
                            .onAppear {
                                isFocused = true
                            }
                        
                        Button {
                            withAnimation {
                                searchResults = nil
                                exploreSearchVM.text = ""
                                isSearching = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 50)
                        }
                    }
                }
                .frame(maxWidth: isSearching ? .infinity : searchResults == nil ? 60 : .infinity)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.themeBG.opacity(searchResults == nil ? 1 : 0.8)))
                .background(RoundedRectangle(cornerRadius: 15).stroke(isSearching ? Color.accentColor.opacity(0.3) : Color.themePrimary, lineWidth: 2))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            if isSearching {
                Picker("Scope", selection: $exploreSearchVM.scope) {
                    ForEach(SearchScopes.allCases) { scope in
                        Text(scope.title)
                            .tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                TabView(selection: $exploreSearchVM.scope) {
                    VStack(spacing: 0) {
                        if !exploreSearchVM.placeSearchResults.isEmpty {
                            Button {
                                withAnimation {
                                    isSearching = false
                                }
                                
                                self.searchResults = exploreSearchVM.placeSearchResults
                                
                                if let region = getClusterRegion(coordinates: exploreSearchVM.placeSearchResults.map { $0.placemark.coordinate }) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            panToRegion(region)
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
                            .padding(.horizontal)
                            .padding(.bottom, 10)
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
                    
                    List(exploreSearchVM.eventsSearchResult) { event in
                        EventCard(event: event)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.interactively)
                    .opacity(exploreSearchVM.isLoading ? 0.6 : 1)
                    .tag(SearchScopes.events)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .transition(AnyTransition.opacity.animation(.easeInOut))
                .onDisappear {
                    self.isFocused = false
                }
            }
        }
        .background(isSearching ? Color.themeBG.ignoresSafeArea() : nil)
    }
}

fileprivate struct PlaceCard: View {
    let place: MKMapItem
    
    var body: some View {
        if let title = place.name {
            NavigationLink(value: AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title))) {
                HStack {
                    Group {
                        if let pointOfInterestCategory = place.pointOfInterestCategory {
                            pointOfInterestCategory.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 24))
                        }
                    }
                    .frame(width: 42, height: 42)
                    .foregroundStyle(.secondary)
                    
                    VStack {
                        Text(place.name ?? place.placemark.name ?? "Unknown")
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let distance = distanceFromMe(lat: place.placemark.coordinate.latitude, lng: place.placemark.coordinate.longitude, unit: .miles) {
                            Text(String(format: "%.1f", distance) + " Miles away")
                                .foregroundStyle(.secondary)
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("\(place.placemark.postalAddress?.city ?? "-"), \(place.placemark.postalAddress?.street ?? "-")")
                                .font(.custom(style: .caption))
                                .foregroundStyle(.secondary)
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
    let user: UserEssentials
    
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

fileprivate struct EventCard: View {
    let event: Event
    
    var body: some View {
        NavigationLink(value: AppRoute.event(.data(event))) {
            HStack {
                ImageLoader(event.logo)
                    .frame(width: 42, height: 42)
                    .clipShape(.rect(cornerRadius: 10))
                
                VStack {
                    Text(event.name)
                        .font(.custom(style: .body))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let address = event.place.location.address {
                        Text(address)
                            .font(.custom(style: .caption))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
