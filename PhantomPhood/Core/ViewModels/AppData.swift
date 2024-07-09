//
//  AppData.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import SwiftUI

final class AppData: ObservableObject {
    static var shared = AppData()
    private init() {}
    
    // Main Navigation Stack
    @Published var navStack: [AppRoute] = []
    
    // Authentication Navigation Stack (Only before sign-in)
    @Published var authNavStack: [AuthRoute] = []
    
    // Root Active Tab
    @Published var activeTab: Tab = .home
    
    // Home Active Tab
    @Published var homeActiveTab: HomeTab = .following
        
    @Published var tappedTwice: Tab? = nil
    
    var tabViewSelectionHandler: Binding<Tab> {
        Binding {
            self.activeTab
        } set: {
            if $0 == self.activeTab {
                self.tappedTwice = $0
            } else {
                self.activeTab = $0
            }
        }
    }
    
    @MainActor
    func reset() {
        self.navStack.removeAll()
        self.authNavStack.removeAll()
                
        self.activeTab = .home
    }
    
    func goTo(_ route: AppRoute) {
        DispatchQueue.main.async {
            self.navStack.append(route)
        }
    }
    
    func goBack() {
        guard !navStack.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.navStack.removeLast()
        }
    }
    
    func goToUser(_ id: String) {
        if let currentUserId = Authentication.shared.currentUser?.id, currentUserId == id {
            return
        }
        
        DispatchQueue.main.async {
            self.goTo(.userProfile(userId: id))
        }
    }
}

enum HomeTab: String {
    case forYou = "For You"
    case following = "Following"
}
