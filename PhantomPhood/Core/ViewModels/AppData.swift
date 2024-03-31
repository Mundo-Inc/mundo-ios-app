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
    
    // Active Tab
    @Published var activeTab: Tab = .home
        
    // Home Tab
    @Published var homeNavStack: [AppRoute] = []
    @Published var homeActiveTab: HomeTab = .forYou
    
    @Published var myProfileActiveTab: MyProfileActiveTab = .stats
    @Published var showEditProfile: Bool = false
    
    // Authentication Tab (Only before sign-in)
    @Published var authNavStack: [AuthRoute] = []
    
    @Published var tappedTwice: Tab? = nil
    
    var tabViewSelectionHandler: Binding<Tab> {
        Binding {
            self.activeTab
        } set: {
            if $0 == self.activeTab {
                switch self.activeTab {
                case .home:
                    self.tappedTwice = $0
                case .explore:
                    self.tappedTwice = $0
                case .rewardsHub:
                    self.tappedTwice = $0
                case .myProfile:
                    self.tappedTwice = $0
                }
            } else {
                self.activeTab = $0
            }
        }
    }
    
    func reset() {
        self.activeTab = .home
        
        self.homeNavStack.removeAll()
        self.authNavStack.removeAll()
        
        self.myProfileActiveTab = .stats
        self.showEditProfile = false
    }
    
    func goTo(_ route: AppRoute) {
        self.homeNavStack.append(route)
    }
    
    func goBack() {
        self.homeNavStack.removeLast()
    }
    
    func goToUser(_ id: String) {
        if let currentUserId = Authentication.shared.currentUser?.id, currentUserId == id {
            self.activeTab = .myProfile
            return
        }
        self.goTo(.userProfile(userId: id))
    }
}

enum HomeTab: String {
    case forYou = "For You"
    case following = "Following"
}
