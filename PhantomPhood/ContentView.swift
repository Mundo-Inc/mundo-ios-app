//
//  ContentView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var selectReactionsVM = SelectReactionsVM.shared
    @ObservedObject private var commentsVM = CommentsVM.shared
    @ObservedObject private var placeSelectorVM = PlaceSelectorVM.shared
    
    @StateObject private var onboardingVM = OnboardingVM()
    
    @State private var showActions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let user = auth.currentUser, user.accepted_eula != nil, !onboardingVM.isPresented {
                TabView(selection: appData.tabViewSelectionHandler) {
                    HomeView()
                        .tag(Tab.home)
                        .toolbar(.hidden, for: .tabBar)
                    
                    ExploreView()
                        .tag(Tab.explore)
                        .toolbar(.hidden, for: .tabBar)
                    
                    RewardsHubView()
                        .tag(Tab.rewardsHub)
                        .toolbar(.hidden, for: .tabBar)
                    
                    MyProfile()
                        .tag(Tab.myProfile)
                        .toolbar(.hidden, for: .tabBar)
                }
            } else {
                EmptyView()
            }
            
            Divider()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainTabBarView(selection: appData.tabViewSelectionHandler, showActions: $showActions)
                .sheet(isPresented: $showActions) {
                    QuickActionsView()
                }
                .sheet(isPresented: $placeSelectorVM.isPresented) {
                    PlaceSelectorView()
                        .presentationDetents([.fraction(0.99)])
                }
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: Binding(get: {
            if let user = auth.currentUser, user.accepted_eula != nil {
                return onboardingVM.isPresented
            }
            return false
        }, set: { value in
            onboardingVM.isPresented = value
        })) {
            OnboardingView(vm: onboardingVM)
        }
        .sheet(isPresented: $selectReactionsVM.isPresented, content: {
            if #available(iOS 17.0, *) {
                SelectReactionsView(vm: selectReactionsVM)
                    .presentationBackground(.thinMaterial)
            } else {
                SelectReactionsView(vm: selectReactionsVM)
            }
        })
        .sheet(isPresented: Binding(optionalValue: $commentsVM.currentActivityId), onDismiss: {
            commentsVM.onDismiss()
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
