//
//  AppRouter.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/24/23.
//

import SwiftUI
import BranchSDK

struct AppRouter: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var network = NetworkMonitor()
    
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var toastVM = ToastVM.shared
    @ObservedObject private var appGeneralVM = AppGeneralVM.shared
    
    @AppStorage(K.UserDefaults.theme) var theme: String = ""
    
    var body: some View {
        ZStack {
            if auth.userSession != nil {
                if let user = auth.currentUser {
                    if user.acceptedEula != nil {
                        ContentView()
                    } else {
                        CompleteTheUserInfoView()
                    }
                } else {
                    FirstLoadingView()
                }
            } else {
                AuthWelcomeView()
            }
            
            VStack(spacing: 10) {
                ForEach(toastVM.toasts) { toast in
                    ToastItem(toast)
                }
            }
            .animation(.linear(duration: 0.5), value: toastVM.toasts.count)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top)
        }
        .environmentObject(network)
        .preferredColorScheme(theme == "" ? .none : theme == "dark" ? .dark : .light)
        .fullScreenCover(isPresented: $appGeneralVM.showForceUpdate) {
            ZStack {
                if let appInfo = appGeneralVM.appInfo {
                    VStack {
                        Spacer()
                        
                        VStack {
                            HStack {
                                Image(systemName: "app")
                                Text("App Version:")
                                Spacer()
                                Text(appGeneralVM.appVersion)
                            }
                            HStack {
                                Image(systemName: "lessthan.circle")
                                Text("Min Operational Version:")
                                Spacer()
                                Text(appInfo.minOperationalVersion)
                            }
                            HStack {
                                Image(systemName: "app.fill")
                                Text("Latest Version:")
                                Spacer()
                                Text(appInfo.latestAppVersion)
                            }
                        }
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                        .alert("Update Required", isPresented: Binding(get: {
                            true
                        }, set: { _ in })) {
                            if let url = URL(string: "https://apps.apple.com/app/id6450897373") {
                                Link(destination: url) {
                                    Text("Update")
                                        .frame(maxWidth: .infinity)
                                        .cfont(.headline)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                            }
                        } message: {
                            Text(appInfo.message)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .cfont(.body)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(alignment: .topTrailing) {
                Image(.Logo.tpLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
                    .rotationEffect(.degrees(-90))
                    .offset(x: 55, y: 20)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                Task {
                    await appGeneralVM.checkVersion()
                }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                    Task {
                        do {
                            try await VideoCachingManager.shared.clearOldCacheFiles()
                        } catch {
                            print("Error clearOldCacheFiles", error)
                        }
                    }
                }
            case .background, .inactive:
                // Considered as a graceful termination
                UserDefaults.standard.set(true, forKey: K.UserDefaults.appTerminatedGracefully)
            default:
                break
            }
        }
        .onOpenURL(perform: { url in
            Branch.getInstance().handleDeepLink(url)
        })
    }
}

#Preview {
    AppRouter()
}
