//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

enum PlaceTypes: String, Identifiable, CaseIterable {
    case restaurant
    case cafe
    case bar
    
    var id: Self { self }
}

struct HomeView: View {
    @EnvironmentObject var auth: Authentication
    @EnvironmentObject private var appData: AppData
    
    @State var searchText: String = ""
    @State var tokens: [PlaceTypes] = []
    @State var suggestedTokens: [PlaceTypes] = [.bar]
    
    @State var searchScopes: String = "Places"
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            FeedView(searchText: $searchText)
            
            .navigationDestination(for: HomeStack.self) { link in
                switch link {
                case .notifications:
                    NotificationsView()
                case .place(let id):
                    PlaceView(id: id)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
//        .searchable(text: $searchText)
//        .searchable(text: $searchText) {
//            Label("Restaurants", systemImage: "fork.knife")
//                .searchCompletion("restaurant")
//            Label("Bars", systemImage: "wineglass")
//                .searchCompletion("restaurant")
//            Label("Cafe", systemImage: "cup.and.saucer.fill")
//                .searchCompletion("restaurant")
//        }
        .searchable(text: $searchText, tokens: $tokens, suggestedTokens: $suggestedTokens, token: { token in
            switch token {
            case .restaurant: Text("Restaurant")
            case .bar: Text("Bar")
            case .cafe: Text("Cafe")
            }
        })
        .searchScopes($searchScopes, activation: .onSearchPresentation, {
            Text("Places")
                .tag("Places")
            Text("Users")
                .tag("Users")
        })
//        .onChange(of: searchScopes, {
//            print("Changed to \(searchScopes)")
//        })
        .onChange(of: searchScopes, perform: { value in
            tokens.removeAll()
            if value == "Places" {
                suggestedTokens = [.bar]
            } else {
                suggestedTokens = [.cafe, .restaurant]
            }
        })
        .onSubmit(of: .search) {
            print(searchText)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppData())
            .environmentObject(Authentication())
    }
}
