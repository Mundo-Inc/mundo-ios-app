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
        ZStack {
            Color("Background").ignoresSafeArea()
            
            TabView(selection: $appData.activeTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: Tab.home.icon)
                    }
                    .tag(Tab.home)
                
                MapView()
                    .tabItem {
                        Image(systemName: Tab.map.icon)
                    }
                    .tag(Tab.map)
                
                
                LeaderboardView()
                    .tabItem {
                        Image(systemName: Tab.leaderboard.icon)
                    }
                    .tag(Tab.leaderboard)
                
                MyProfile()
                    .tabItem {
                        Image(systemName: Tab.myProfile.icon)
                    }
                    .tag(Tab.myProfile)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
