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
    @Published var mapNavStack: [MapStack] = []
    
    // Leaderboard Tab
    @Published var leaderboardNavStack: [LeaderboardStack] = []
    
    // Home Tab
    @Published var homeNavStack: [HomeStack] = []
    @Published var homeActiveTab: HomeTab = .forYou
    
    // My Profile Tab
    @Published var myProfileNavStack: [MyProfileStack] = []
    @Published var myProfileActiveTab: MyProfileActiveTab = .stats
    @Published var showEditProfile: Bool = false
    
    // Authentication Tab (Only before sign-in)
    @Published var authNavStack: [AuthStack] = []
    
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
                case .map:
                    if !self.mapNavStack.isEmpty {
                        self.mapNavStack.removeLast()
                    } else {
                        self.tappedTwice = $0
                    }
                case .leaderboard:
                    if !self.leaderboardNavStack.isEmpty {
                        self.leaderboardNavStack.removeLast()
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
        self.mapNavStack.removeAll()
        self.leaderboardNavStack.removeAll()
        self.authNavStack.removeAll()
        
        self.myProfileNavStack.removeAll()
        self.myProfileActiveTab = .stats
        self.showEditProfile = false
    }
    
    func goToUser(_ id: String, _ currentUserId: String? = nil) {
        if let userId = currentUserId, userId == id {
            self.activeTab = .myProfile
            return
        }
        switch self.activeTab {
        case .home:
            self.homeNavStack.append(.userProfile(userId: id))
        case .map:
            self.mapNavStack.append(.userProfile(userId: id))
        case .leaderboard:
            self.leaderboardNavStack.append(.userProfile(userId: id))
        case .myProfile:
            self.myProfileNavStack.append(.userProfile(userId: id))
        }
    }
}

enum HomeTab: String {
    case forYou = "For You"
    case followings = "Followings"
}
