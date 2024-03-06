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
    
    @StateObject private var actionManager = ActionManager()
    @StateObject private var alertManager = AlertManager()
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let user = auth.currentUser, user.acceptedEula != nil, !onboardingVM.isPresented {
                TabView(selection: appData.tabViewSelectionHandler) {
                    Group {
                        HomeView()
                            .tag(Tab.home)
                        
                        ExploreView()
                            .tag(Tab.explore)
                        
                        RewardsHubView()
                            .tag(Tab.rewardsHub)
                        
                        MyProfile()
                            .tag(Tab.myProfile)
                    }
                    .toolbar(.hidden, for: .tabBar)
                }
                .environmentObject(alertManager)
                .environmentObject(actionManager)
                .alert("Confirmation", isPresented: Binding(optionalValue: $alertManager.value), presenting: alertManager.value) { item in
                    Button {
                        item.callback()
                    } label: {
                        Text("Yes")
                    }
                    
                    Button("Cancel", role: .cancel) {
                        alertManager.value = nil
                    }
                } message: { item in
                    Text(item.message)
                }
                .confirmationDialog("Actions", isPresented: Binding(optionalValue: $actionManager.value), presenting: actionManager.value) { value in
                    ForEach(value) { item in
                        Button(item.title) {
                            if let alertMessage = item.alertMessage {
                                alertManager.value = .init(message: alertMessage, callback: item.callback)
                            } else {
                                item.callback()
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
            
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
            if let user = auth.currentUser, user.acceptedEula != nil {
                return onboardingVM.isPresented
            }
            return false
        }, set: { value in
            onboardingVM.isPresented = value
        })) {
            OnboardingView(vm: onboardingVM)
        }
        .sheet(isPresented: $selectReactionsVM.isPresented, content: {
            if #available(iOS 16.4, *) {
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
