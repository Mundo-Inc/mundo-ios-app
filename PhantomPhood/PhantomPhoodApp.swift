//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

@main
struct PhantomPhoodApp: App {
    @StateObject private var auth = Authentication()
    @StateObject private var appData: AppData = AppData()
    
    private func getKeyValue(_ key: String, string: String) -> String? {
        let components = string.components(separatedBy: "/")
        for component in components {
            if component.contains("\(key)=") {
                return component.replacingOccurrences(of: "\(key)=", with: "")
            }
        }
        return nil
    }
    
    var body: some Scene {
        WindowGroup {

            Group {
                if auth.isSignedIn {
                    if let _ = auth.user {
                        ContentView()
                    } else {
                        ProgressView()
                    }
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(auth)
            .environmentObject(appData)
            .onOpenURL { url in
                // return if not signed in
                guard auth.isSignedIn else { return }
                
                let string = url.absoluteString.replacingOccurrences(of: "phph://", with: "")
                let components = string.components(separatedBy: "/")
                
                for component in components {
                    if component.contains("tab=") {
                        let tabRawValue = component.replacingOccurrences(of: "tab=", with: "")
                        if let requestedTab = Tab.convert(from: tabRawValue) {
                            appData.activeTab = requestedTab
                        }
                    } else {
                        // return if tab is not specified
                        return
                    }
                    
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
                            default:
                                break
                            }
                        }
                    }
                }
                
            }
        }
    }
}
