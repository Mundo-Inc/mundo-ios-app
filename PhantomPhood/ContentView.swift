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
    
    var body: some View {
        TabView(selection: appData.tabViewSelectionHandler) {
            HomeView()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: Tab.home.icon)
                    }
                }
                .tag(Tab.home)
            
            MapView()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        Image(systemName: Tab.map.icon)
                    }
                }
                .tag(Tab.map)
            
            
            LeaderboardView()
                .tabItem {
                    Label {
                        Text("Leaderboard")
                    } icon: {
                        Image(systemName: Tab.leaderboard.icon)
                    }
                }
                .tag(Tab.leaderboard)
            
            MyProfile()
                .tabItem {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image(systemName: Tab.myProfile.icon)
                    }
                }
                .tag(Tab.myProfile)
        }
        .sheet(isPresented: $selectReactionsViewModel.isPresented, content: {
            if #available(iOS 17.0, *) {
                SelectReactionsView()
                    .presentationBackground(.thinMaterial)
            } else {
                SelectReactionsView()
            }
        })
        .sheet(isPresented: Binding(optionalValue: $commentsViewModel.currentActivityId), onDismiss: {
            commentsViewModel.onDismiss()
        }, content: {
            CommentsView()
        })
        .onAppear {
            ContactsService.shared.tryToSyncContacts()
        }
    }
}

#Preview {
    ContentView()
}
