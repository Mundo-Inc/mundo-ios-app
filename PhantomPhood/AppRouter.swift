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
    
    @AppStorage("theme") var theme: String = ""
    
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
                WelcomeView()
            }
            
            VStack(spacing: 5) {
                ForEach(toastVM.toasts) { toast in
                    VStack {
                        Text(toast.title)
                            .font(.custom(style: .headline))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(toast.message)
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(toast.type == .success ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    }
                    .clipShape(.rect(cornerRadius: 10))
                    .onTapGesture {
                        toastVM.remove(id: toast.id)
                    }
                    .padding(.horizontal)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                    .animation(.bouncy, value: toastVM.toasts.count)
                }
            }
            .animation(.bouncy, value: toastVM.toasts.count)
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
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                        .alert("Update Required", isPresented: Binding(get: {
                            true
                        }, set: { _ in })) {
                            if let url = URL(string: "https://apps.apple.com/app/phantom-phood/id6450897373") {
                                Link(destination: url) {
                                    Text("Update")
                                        .frame(maxWidth: .infinity)
                                        .font(.custom(style: .headline))
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
            .font(.custom(style: .body))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(alignment: .topTrailing) {
                Image(.hangingPhantom)
                    .resizable()
                    .frame(width: 100, height: 191)
                    .padding(.trailing)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                Task {
                    await appGeneralVM.checkVersion()
                }
            case .background, .inactive:
                // Considered as a graceful termination
                UserDefaults.standard.set(true, forKey: "AppTerminatedGracefully")
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
