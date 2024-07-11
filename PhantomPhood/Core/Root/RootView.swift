//
//  RootView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/30/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var inviteFriendsVM = InviteFriendsVM()
    
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
                
                MyProfileView()
                    .tag(Tab.myProfile)
            }
            .environmentObject(inviteFriendsVM)
            
            MainTabBarView(selection: appData.tabViewSelectionHandler, showActions: $showActions)
                .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if appData.activeTab == .myProfile {
                ToolbarItem(placement: .topBarLeading) {
                    Text("My Profile")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: AppRoute.settings) {
                        Image(systemName: "gear")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
        }
        .toolbarBackground(appData.activeTab == .myProfile ? Color.themePrimary : Color.clear, for: .navigationBar)
        .toolbarBackground(appData.activeTab == .myProfile ? .visible : .hidden, for: .navigationBar)
        .sheet(isPresented: $showActions) {
            QuickActionsView()
        }
        .handleNavigationDestination()
    }
}

#Preview {
    RootView()
}
