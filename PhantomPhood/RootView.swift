//
//  RootView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/30/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var appData = AppData.shared
    @State private var showActions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: appData.tabViewSelectionHandler) {
                HomeView()
                    .tag(Tab.home)
                
                ExploreView()
                    .tag(Tab.explore)
                
                RewardsHubView()
                    .tag(Tab.rewardsHub)
                
                MyProfile()
                    .tag(Tab.myProfile)
            }
            
            MainTabBarView(selection: appData.tabViewSelectionHandler, showActions: $showActions)
                .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showActions) {
            QuickActionsView()
        }
        .handleNavigationDestination()
    }
}

#Preview {
    RootView()
}
