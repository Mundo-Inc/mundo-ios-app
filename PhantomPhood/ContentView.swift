//
//  ContentView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        TabView(selection: $appData.activeTab) {
            HomeView()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: Tab.home.icon)
                    }
                }
                .tag(Tab.home)
            
            if #available(iOS 17.0, *) {
                MapView()
                    .tabItem {
                        Label {
                            Text("Explore")
                        } icon: {
                            Image(systemName: Tab.map.icon)
                        }
                    }
                    .tag(Tab.map)
            } else {
                RoundedRectangle(cornerRadius: 25.0)
            }
            
            
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
