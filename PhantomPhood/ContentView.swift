//
//  ContentView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    @ObservedObject private var addReviewVM = AddReviewVM.shared
    
    @StateObject private var searchViewModel = SearchViewModel()
    
    @State private var showActions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: appData.tabViewSelectionHandler) {
                HomeView()
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)
                
                MapView()
                    .tag(Tab.map)
                    .toolbar(.hidden, for: .tabBar)
                
                
                LeaderboardView()
                    .tag(Tab.leaderboard)
                    .toolbar(.hidden, for: .tabBar)
                
                MyProfile()
                    .tag(Tab.myProfile)
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(searchViewModel)
            
            MainTabBarView(selection: appData.tabViewSelectionHandler, showActions: $showActions)
                .sheet(isPresented: $showActions) {
                    QuickActionsView(searchViewModel: searchViewModel)
                }
                .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
                    searchViewModel.tokens.removeAll()
                    searchViewModel.text = ""
                }) {
                    SearchView(vm: searchViewModel) { place in
                        if let title = place.name {
                            appData.homeNavStack.append(AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                        }
                    } onUserSelect: { user in
                        appData.homeNavStack.append(AppRoute.userProfile(userId: user.id))
                    }
                }
        }
        .sheet(isPresented: $selectReactionsViewModel.isPresented, content: {
            if #available(iOS 17.0, *) {
                SelectReactionsView(vm: selectReactionsViewModel)
                    .presentationBackground(.thinMaterial)
            } else {
                SelectReactionsView(vm: selectReactionsViewModel)
            }
        })
        .sheet(isPresented: Binding(optionalValue: $commentsViewModel.currentActivityId), onDismiss: {
            commentsViewModel.onDismiss()
        }, content: {
            CommentsView()
        })
        .fullScreenCover(isPresented: $addReviewVM.isPresented) {
            AddReviewView()
        }
        .onAppear {
            ContactsService.shared.tryToSyncContacts()
        }
    }
}

#Preview {
    ContentView()
}
