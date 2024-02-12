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
    
    // Map Tab
    @Published var exploreNavStack: [AppRoute] = []
    
    // Rewards Hub Tab
    @Published var rewardsHubNavStack: [AppRoute] = []
    
    // Home Tab
    @Published var homeNavStack: [AppRoute] = []
    @Published var homeActiveTab: HomeTab = .forYou
    
    // My Profile Tab
    @Published var myProfileNavStack: [AppRoute] = []
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
                    if !self.homeNavStack.isEmpty {
                        self.homeNavStack.removeLast()
                    } else {
                        self.tappedTwice = $0
                    }
                case .explore:
                    if !self.exploreNavStack.isEmpty {
                        self.exploreNavStack.removeLast()
                    } else {
                        self.tappedTwice = $0
                    }
                case .rewardsHub:
                    if !self.rewardsHubNavStack.isEmpty {
                        self.rewardsHubNavStack.removeLast()
                    } else {
                        self.tappedTwice = $0
                    }
                case .myProfile:
                    if !self.myProfileNavStack.isEmpty {
                        self.myProfileNavStack.removeLast()
                    } else {
                        self.tappedTwice = $0
                    }
                }
            }
            self.activeTab = $0
        }
    }
    
    func reset() {
        self.activeTab = .home
        
        self.homeNavStack.removeAll()
        self.exploreNavStack.removeAll()
        self.rewardsHubNavStack.removeAll()
        self.authNavStack.removeAll()
        
        self.myProfileNavStack.removeAll()
        self.myProfileActiveTab = .stats
        self.showEditProfile = false
    }
    
    func goTo(_ route: AppRoute) {
        switch self.activeTab {
        case .home:
            self.homeNavStack.append(route)
        case .explore:
            self.exploreNavStack.append(route)
        case .rewardsHub:
            self.rewardsHubNavStack.append(route)
        case .myProfile:
            self.myProfileNavStack.append(route)
        }
    }
    
    func goBack() {
        switch self.activeTab {
        case .home:
            self.homeNavStack.removeLast()
        case .explore:
            self.exploreNavStack.removeLast()
        case .rewardsHub:
            self.rewardsHubNavStack.removeLast()
        case .myProfile:
            self.myProfileNavStack.removeLast()
        }
    }
    
    func goToUser(_ id: String, _ currentUserId: String? = nil) {
        if let userId = currentUserId, userId == id {
            self.activeTab = .myProfile
            return
        }
        self.goTo(.userProfile(userId: id))
    }
    
    func getActiveRotue() -> AppRoute? {
        switch self.activeTab {
        case .home:
            return self.homeNavStack.last
        case .explore:
            return self.exploreNavStack.last
        case .rewardsHub:
            return self.rewardsHubNavStack.last
        case .myProfile:
            return self.myProfileNavStack.last
        }
    }
}

enum HomeTab: String {
    case forYou = "For You"
    case followings = "Followings"
}
