//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Firebase
import GoogleSignIn
import UserNotifications

@main
struct PhantomPhoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var auth = Authentication.shared
    @StateObject private var appData: AppData = AppData.shared
    @StateObject var locationManager = LocationManager.shared
    @StateObject private var toastViewModel = ToastViewModel.shared
    
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
    
    init() {
        URLCache.shared.memoryCapacity = 50_000_000 // ~50 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
    }
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                if auth.userSession != nil {
                    if let user = auth.currentUser {
                        if user.accepted_eula != nil {
                            ContentView()
                                .environmentObject(locationManager)
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
                guard auth.userSession != nil else { return }
                
                let string = url.absoluteString.replacingOccurrences(of: "phantom://", with: "")
                let components = string.components(separatedBy: "/")
                
                var tabSet = false
                for component in components {
                    print(component)
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
                
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        //        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        
        UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler()
    }
}

// SignIn with Google
extension AppDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
