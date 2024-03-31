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
    
    @StateObject private var actionManager = ActionManager()
    @StateObject private var alertManager = AlertManager()
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            RootView()
        }
        .ignoresSafeArea(.keyboard)
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
        .sheet(isPresented: $placeSelectorVM.isPresented) {
            PlaceSelectorView()
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
        .onAppear {
            ContactsService.shared.tryToSyncContacts()
        }
    }
}

#Preview {
    ContentView()
}
