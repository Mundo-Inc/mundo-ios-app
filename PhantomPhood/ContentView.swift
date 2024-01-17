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
    
    @StateObject private var placeSelectorVM = PlaceSelectorVM()
    
    @State private var showActions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: appData.tabViewSelectionHandler) {
                HomeView()
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar)
                
                ExploreView()
                    .tag(Tab.explore)
                    .toolbar(.hidden, for: .tabBar)
                
                
                LeaderboardView()
                    .tag(Tab.leaderboard)
                    .toolbar(.hidden, for: .tabBar)
                
                MyProfile()
                    .tag(Tab.myProfile)
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(placeSelectorVM)
            
            MainTabBarView(selection: appData.tabViewSelectionHandler, showActions: $showActions)
                .sheet(isPresented: $showActions) {
                    QuickActionsView()
                        .environmentObject(placeSelectorVM)
                }
                .sheet(isPresented: $placeSelectorVM.isPresented) {
                    PlaceSelectorView(placeSelectorVM: placeSelectorVM) { place in
                        if let title = place.name {
                            appData.homeNavStack.append(AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: placeSelectorVM.tokens.contains(.addReview) ? .addReview : placeSelectorVM.tokens.contains(.checkin) ? .checkin : nil))
                        }
                    }
                }
        }
        .ignoresSafeArea(.keyboard) // TODO: Test to see if this causes any bugs
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
