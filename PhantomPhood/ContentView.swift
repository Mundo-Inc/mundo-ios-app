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
    @ObservedObject private var sheetsManager = SheetsManager.shared
    
    @StateObject private var onboardingVM = OnboardingVM()
    
    @StateObject private var actionManager = ActionManager()
    @StateObject private var alertManager = AlertManager()
    
    var body: some View {
        NavigationStack(path: $appData.navStack) {
            RootView()
        }
        .environmentObject(alertManager)
        .environmentObject(actionManager)
        .alert("Confirmation", isPresented: Binding(optionalValue: $alertManager.value), presenting: alertManager.value) { item in
            Button(role: item.role, action: item.callback) {
                Text(item.confirmationText)
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
        .sheet(item: $sheetsManager.presenting) { item in
            switch item {
            case .placeSelector(let onSelect):
                PlaceSelectorView(onSelect: onSelect)
            case .reactionSelector(let onSelect):
                if #available(iOS 16.4, *) {
                    SelectReactionsView(onSelect: onSelect)
                        .presentationBackground(.thinMaterial)
                } else {
                    SelectReactionsView(onSelect: onSelect)
                }
            case .comments(let activityId):
                CommentsView(for: activityId)
            case .gifting(let idOrData):
                if #available(iOS 16.4, *) {
                    GiftingView(idOrData)
                        .presentationBackground(.thinMaterial)
                } else {
                    GiftingView(idOrData)
                }
            }
        }
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
//        .task {
//            guard auth.currentUser != nil else { return }
//            
//            if ConversationsManager.shared.client.conversationsClient == nil || ConversationsManager.shared.myUser == nil {
//                do {
//                    try await ConversationsManager.shared.client.create()
//                    ConversationsManager.shared.registerForTyping()
//                } catch {
//                    presentErrorToast(error, debug: "Error creating twilio client")
//                }
//            }
//            
////            ContactsService.shared.tryToSyncContacts()
//        }
    }
}

#Preview {
    ContentView()
}
