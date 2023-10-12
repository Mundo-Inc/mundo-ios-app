//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: Authentication
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject var locationManager: LocationManager
                    
    @ObservedObject var searchViewModel = SearchViewModel.shared
    
    @State var showActions: Bool = false
    @State var isSearching = false
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            ZStack(alignment: .bottomTrailing) {
                FeedView()
                
                Button {
                    showActions.toggle()
                } label: {
                    Circle()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }

                        .padding(.trailing)
                        .padding(.bottom)
                }
            }
            .navigationDestination(for: HomeStack.self) { link in
                switch link {
                case .notifications:
                    NotificationsView()
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
        .sheet(isPresented: $showActions) {
            VStack {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 30, height: 3)
                    .padding(.top)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Button {
                    searchViewModel.showSearch = true
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.checkin]
                    showActions = false
                } label: {
                    HStack {
                        Image(systemName: "checkmark.diamond")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Check-in")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Check in to places that you go!")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Button {
                    searchViewModel.showSearch = true
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.addReview]
                    showActions = false
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Review")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Add a review to a place that you’ve been")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .presentationDetents([.height(250)])
        }
//        .searchable(text: $searchText) {
//            Label("Restaurants", systemImage: "fork.knife")
//                .searchCompletion("restaurant")
//            Label("Bars", systemImage: "wineglass")
//                .searchCompletion("restaurant")
//            Label("Cafe", systemImage: "cup.and.saucer.fill")
//                .searchCompletion("restaurant")
//        }
//        .searchable(text: $searchText, tokens: $tokens, suggestedTokens: $suggestedTokens, token: { token in
//            switch token {
//            case .restaurant: Text("Restaurant")
//            case .bar: Text("Bar")
//            case .cafe: Text("Cafe")
//            }
//        })
//        .onChange(of: searchScopes, {
//            print("Changed to \(searchScopes)")
//        })
//        .onChange(of: searchScopes, perform: { value in
//            tokens.removeAll()
//            if value == "Places" {
//                suggestedTokens = [.bar]
//            } else {
//                suggestedTokens = [.cafe, .restaurant]
//            }
//        })
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppData())
            .environmentObject(Authentication())
            .environmentObject(LocationManager())
    }
}
