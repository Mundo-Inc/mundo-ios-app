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
    @ObservedObject var searchViewModel = SearchViewModel.shared
    
    @Binding var path: [HomeStack]
    
    func closeSearch() {
        dismissSearch()
        searchViewModel.showSearch = false
        searchViewModel.tokens.removeAll()
        searchViewModel.text = ""
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $searchViewModel.scope) {
                ScrollView {
                    VStack {
                        Label {
                            Text("Near you")
                        } icon: {
                            Image(systemName: "location.fill")
                        }
                        .padding(.vertical)
                        
                        
                        ForEach(searchViewModel.placeSearchResults) { place in
                            PlaceCard(place: place, path: $path, closeSearch: closeSearch)
                            Divider()
                        }
                        if searchViewModel.isLoading {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollDismissesKeyboard(.interactively)
                .tag(SearchScopes.places)
                
                if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
                    ScrollView {
                        VStack {
                            ForEach(searchViewModel.userSearchResults) { user in
                                UserCard(user: user, path: $path, closeSearch: closeSearch)
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
            .searchable(text: $searchViewModel.text, tokens: $searchViewModel.tokens, placement: .navigationBarDrawer(displayMode: .always), token: { token in
                switch token {
                case .checkin: Text(SearchTokens.checkin.rawValue)
                case .addReview: Text(SearchTokens.addReview.rawValue)
                }
            })
            .searchScopes($searchViewModel.scope, activation: .onSearchPresentation, {
                if !searchViewModel.tokens.contains(.checkin) && !searchViewModel.tokens.contains(.checkin) {
                    ForEach(SearchScopes.allCases) { scope in
                        Text(scope.rawValue)
                            .tag(scope)
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
    let place: CompactPlace
    @Binding var path: [HomeStack]
    
    let closeSearch: () -> Void
    
    @ObservedObject var searchViewModel = SearchViewModel.shared
    
    var body: some View {
        Button {
            path.append(HomeStack.place(id: place.id, action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
            closeSearch()
        } label: {
            HStack {
                Circle()
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 42, height: 42)
                    .overlay {
                        Group {
                            if let amenity = place.amenity {
                                switch amenity {
                                case "restaurant", "fast_food":
                                    Image(systemName: "fork.knife")
                                case "cafe":
                                    Image(systemName: "cup.and.saucer")
                                case "bar":
                                    Image(systemName: "wineglass")
                                default:
                                    Image(systemName: "mappin.circle")
                                }
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
    @Binding var path: [HomeStack]
    
    let closeSearch: () -> Void
    
    var body: some View {
        Button {
            path.append(HomeStack.userProfile(id: user.id))
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
    SearchView(path: .constant([]))
}
