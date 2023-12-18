//
//  AppRouter.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/24/23.
//

import SwiftUI

struct AppRouter: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData: AppData = AppData.shared
    @ObservedObject private var toastViewModel = ToastViewModel.shared
    @ObservedObject private var appGeneralVM = AppGeneralVM.shared
    @ObservedObject private var emojiesVM = EmojiesVM.shared
    
    @AppStorage("theme") var theme: String = ""
    
    private func getKeyValue(_ key: String, string: String) -> String? {
        let components = string.components(separatedBy: "/")
        for component in components {
            if component.contains("\(key)=") {
                return component.replacingOccurrences(of: "\(key)=", with: "")
            }
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            if auth.userSession != nil {
                if let user = auth.currentUser, !emojiesVM.list.isEmpty {
                    if user.accepted_eula != nil {
                        ContentView()
                    } else {
                        CompleteTheUserInfoView()
                    }
                } else {
                    FirstLoadingView()
                        .zIndex(100)
                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 2)).animation(.easeInOut(duration: 0.5)))
                }
            } else {
                WelcomeView()
            }
            
            VStack(spacing: 5) {
                ForEach(toastViewModel.toasts) { toast in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .foregroundStyle(Color.themePrimary)
                        
                        HStack {
                            switch toast.type {
                            case .success:
                                Image(systemName: "checkmark.rectangle.stack.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.green)
                            case .error:
                                Image(systemName: "exclamationmark.bubble.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.red)
                            }
                            
                            
                            VStack {
                                Text(toast.title)
                                    .font(.custom(style: .body))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(toast.message)
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onTapGesture {
                        toastViewModel.remove(id: toast.id)
                    }
                    .padding(.horizontal)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                    .animation(.bouncy, value: toastViewModel.toasts.count)
                    
                }
            }
            .animation(.bouncy, value: toastViewModel.toasts.count)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top)
        }
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
            default:
                break
            }
        }
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // return if not signed in
        guard auth.userSession != nil, let scheme = url.scheme else { return }
        
        if scheme == "phantom" {
            let string = url.absoluteString.replacingOccurrences(of: "phantom://", with: "")
            let components = string.components(separatedBy: "/")
            
            var tabSet = false
            for component in components {
                if component.contains("tab=") {
                    let tabRawValue = component.replacingOccurrences(of: "tab=", with: "")
                    if let requestedTab = Tab.convert(from: tabRawValue) {
                        appData.activeTab = requestedTab
                        tabSet = true
                    }
                } else if !tabSet {
                    // return if tab is not specified
                    return
                }
                // phantom://tab=myProfile/nav=settings
                // phantom://tab=home/nav=place/id=645c1d1ab41f8e12a0d166bc
                if component.contains("nav") {
                    let navRawValue = component.replacingOccurrences(of: "nav=", with: "").lowercased()
                    switch appData.activeTab {
                        // Home Tab
                    case .home:
                        switch navRawValue {
                        case "notifications":
                            appData.homeNavStack.append(.notifications)
                        case "user":
                            if let id = getKeyValue("id", string: string) {
                                appData.homeNavStack.append(.userProfile(id: id.lowercased()))
                            }
                        case "place":
                            if let id = getKeyValue("id", string: string) {
                                appData.homeNavStack.append(.place(id: id.lowercased()))
                            }
                        default:
                            break
                        }
                        // Map Tab
                    case .map:
                        switch navRawValue {
                        case "user":
                            if let id = getKeyValue("id", string: string) {
                                appData.mapNavStack.append(.userProfile(id: id.lowercased()))
                            }
                        case "place":
                            if let id = getKeyValue("id", string: string) {
                                appData.mapNavStack.append(.place(id: id.lowercased()))
                            }
                        default:
                            break
                        }
                        // Leaderboard Tab
                    case .leaderboard:
                        switch navRawValue {
                        case "user":
                            if let id = getKeyValue("id", string: string) {
                                appData.leaderboardNavStack.append(.userProfile(id: id.lowercased()))
                            }
                        default:
                            break
                        }
                        // MyProfile Tab
                    case .myProfile:
                        switch navRawValue {
                        case "user":
                            if let id = getKeyValue("id", string: string) {
                                appData.myProfileNavStack.append(.userProfile(id: id.lowercased()))
                            }
                        case "place":
                            if let id = getKeyValue("id", string: string) {
                                appData.myProfileNavStack.append(.place(id: id.lowercased()))
                            }
                        case "settings":
                            appData.myProfileNavStack.append(.settings)
                        case "myConnections":
                            if let tab = getKeyValue("tab", string: string)?.lowercased(), (tab == "followers" || tab == "followings") {
                                appData.myProfileNavStack.append(.myConnections(initTab: tab == "followers" ? .followers : .followings))
                            }
                        default:
                            break
                        }
                    }
                }
            }
        } else if scheme == "https" {
            let string = url.absoluteString.replacingOccurrences(of: "https://phantomphood.ai/", with: "")
            let components = string.components(separatedBy: "/")
            
            guard let type = components.first, components.endIndex >= 1 else { return }
            
            let id = components[1]
            
            appData.activeTab = .home
            appData.homeNavStack.removeAll()
            
            switch type {
            case "place":
                appData.homeNavStack.append(HomeStack.place(id: id))
            case "user":
                appData.homeNavStack.append(HomeStack.userProfile(id: id))
            case "activity":
                appData.homeNavStack.append(HomeStack.userActivity(id: id))
            default:
                break
            }
        }
    }
}

#Preview {
    AppRouter()
}
