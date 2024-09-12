//
//  AppDelegate.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/2/24.
//

import Firebase
import FirebaseCore
import GoogleSignIn
import BranchSDK
import StripePaymentSheet

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        StripeAPI.defaultPublishableKey = K.ENV.StripeDefaultPublishableKey
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            guard let data = params as? [String: AnyObject] else { return }
            
            if let link = data["+non_branch_link"] as? String, let url = URL(string: link) {
                let universalLinkingManager = UniversalLinkingManager()
                universalLinkingManager.handleIncomingURL(url)
            }
            if let canonicalIdentifier = data["$canonical_identifier"] as? String, let url = URL(string: "\(K.ENV.WebsiteURL)/\(canonicalIdentifier)") {
                let universalLinkingManager = UniversalLinkingManager()
                universalLinkingManager.handleIncomingURL(url)
            }
            // Access and use deep link data here (nav to page, display content, etc.)
        }
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        if UserDefaults.standard.bool(forKey: K.UserDefaults.appTerminatedGracefully) {
            // Reset the flag as we are starting a new session
            UserDefaults.standard.set(false, forKey: K.UserDefaults.appTerminatedGracefully)
        } else {
            // The app did not terminate gracefully last time
            // Perform necessary cleanup or reset operations here
            
            do {
                try DataStack.shared.crashCleanUp()
            } catch {
                presentErrorToast(error, silent: true)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // App is terminating normally
        UserDefaults.standard.set(true, forKey: K.UserDefaults.appTerminatedGracefully)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Get APN token
        if let deviceToken = messaging.apnsToken {
            let apnToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            UserDefaults.standard.set(apnToken, forKey: K.UserDefaults.apnToken)
        }
        
        // Get FCM token
        UserDefaults.standard.set(fcmToken, forKey: K.UserDefaults.fcmToken)
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        for (key, value) in userInfo {
            if let stringKey = key as? String {
                if stringKey == "link", let url = URL(string: "\(K.ENV.WebsiteURL)/\(value)") {
                    var components = url.pathComponents
                    if url.pathComponents.first == "/" {
                        components = Array(components.dropFirst())
                    }
                    
                    guard let route = components.first else {
                        continue
                    }
                    
                    switch route {
                    case "conversation":
                        if let currentRoute = AppData.shared.navStack.last {
                            if case .conversation(let args) = currentRoute, components.count > 1 {
                                if case .id(let covnersationId) = args, components[1] == covnersationId {
                                    return
                                }
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        // Change this to your preferred presentation option
        completionHandler([.banner, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken;
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        for (key, value) in userInfo {
            if let stringKey = key as? String {
                if stringKey == "link", let url = URL(string: "\(K.ENV.WebsiteURL)/\(value)") {
                    let universalLinkingManager = UniversalLinkingManager()
                    universalLinkingManager.handleIncomingURL(url)
                }
            }
        }
        
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
