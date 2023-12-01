//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn
import UserNotifications

@main
struct PhantomPhoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        URLCache.shared.memoryCapacity = 50_000_000 // ~50 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
    }
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
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
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Get APN token
        if let deviceToken = messaging.apnsToken {
            let apnToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            UserDefaults.standard.set(apnToken, forKey: "apnToken")
        }
        
        // Get FCM token
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
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
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
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
