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
    @ObservedObject private var taskManager = TaskManager.shared
    @ObservedObject private var socketService = SocketService.shared
    @ObservedObject private var earningsVM = EarningsVM.shared
    
    @StateObject private var onboardingVM = OnboardingVM()
    
    @StateObject private var actionManager = ActionManager()
    @StateObject private var alertManager = AlertManager()
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    var body: some View {
        NavigationStack(path: $appData.navStack) {
            RootView()
        }
        .overlay(alignment: .top) {
            if let activeTask = taskManager.activeTask {
                VStack {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(maxWidth: .infinity)
                            .frame(height: 4)
                            .foregroundStyle(Color.black.opacity(0.3))
                            
                        
                        TimelineView(.animation(minimumInterval: 1)) { _ in
                            let completionRate = activeTask.completionRate
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: mainWindowSize.width * completionRate, height: 4)
                                .foregroundStyle(Color.white.opacity(0.7))
                                .animation(.easeInOut, value: completionRate)
                        }
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
            
            switch socketService.status {
            case .notConnected, .disconnected, .connecting:
                VStack {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundStyle(socketService.status == .connecting ? Color.orange.opacity(0.5) : Color.red.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .blur(radius: 6)
                    
                    Spacer()
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            default:
                EmptyView()
            }
            
            if !earningsVM.displayChanges.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    
                    ForEach(earningsVM.displayChanges) { item in
                        EarningChangeItem(item)
                    }
                    
                    Spacer()
                }
                .animation(.linear(duration: 0.5), value: earningsVM.displayChanges.count)
                .padding(.all, 25)
                .allowsHitTesting(false)
                .transition(AnyTransition.fade.animation(.easeInOut(duration: 0.3)))
            }
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
                if #available(iOS 16.4, *) {
                    PlaceSelectorView(onSelect: onSelect)
                        .presentationBackground(.thinMaterial)
                } else {
                    PlaceSelectorView(onSelect: onSelect)
                }
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
//            ContactsService.shared.tryToSyncContacts()
//        }
    }
}

#Preview {
    ContentView()
}
