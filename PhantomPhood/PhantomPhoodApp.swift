//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

@main
struct PhantomPhoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Network cache configuration
        configureNetworkCache()
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                AppRouter()
                    .cfont(.body)
                    .environment(\.mainWindowSize, proxy.size)
                    .environment(\.mainWindowSafeAreaInsets, proxy.safeAreaInsets)
            }
        }
    }
    
    private func configureNetworkCache() {
        URLCache.shared.memoryCapacity = 50_000_000
        URLCache.shared.diskCapacity = 1_000_000_000
    }
}
