//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import UserNotifications

@main
struct PhantomPhoodApp: App {
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var appData: AppData = AppData()
    @StateObject var locationManager = LocationManager.shared
    @AppStorage("theme") var theme: String = ""
    
    @StateObject private var toastViewModel = ToastViewModel.shared
    
    private func getKeyValue(_ key: String, string: String) -> String? {
        let components = string.components(separatedBy: "/")
        for component in components {
            if component.contains("\(key)=") {
                return component.replacingOccurrences(of: "\(key)=", with: "")
            }
        }
        return nil
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        URLCache.shared.memoryCapacity = 50_000_000 // ~50 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, error in
//            if error == nil {
//                if status {
//                    UIApplication.shared.registerForRemoteNotifications()
//                    UIApplication.shared.delegate?.application(<#T##UIApplication#>, didRegisterForRemoteNotificationsWithDeviceToken: <#T##Data#>)
//                }
//            }
//        }
    }
    
    var body: some Scene {
        WindowGroup {

            ZStack {
                if auth.isSignedIn {
                    if let _ = auth.user {
                        ContentView()
                            .environmentObject(locationManager)
                    } else {
                        FirstLoadingView()
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
            .environmentObject(auth)
            .environmentObject(appData)
            .onOpenURL { url in
                // return if not signed in
                guard auth.isSignedIn else { return }
                
                let string = url.absoluteString.replacingOccurrences(of: "phantom://", with: "")
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
                    // phph://tab=myProfile/nav=settings
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            guard granted else { return }

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
}
