//
//  AppData.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

class AppData: ObservableObject {
    static var shared = AppData()
    
    @Published var activeTab: Tab = .home
    
    @Published var homeNavStack: [HomeStack] = []
    @Published var mapNavStack: [MapStack] = []
    @Published var leaderboardNavStack: [LeaderboardStack] = []
    @Published var authNavStack: [AuthStack] = []
    
    // My Profile Tab
    @Published var myProfileNavStack: [MyProfileStack] = []
    @Published var myProfileActiveTab: MyProfileActiveTab = .stats
    @Published var showEditProfile: Bool = false
    
    func reset() {
        self.activeTab = .home
        
        self.homeNavStack.removeAll()
        self.mapNavStack.removeAll()
        self.leaderboardNavStack.removeAll()
        self.authNavStack.removeAll()
        
        self.mapNavStack.removeAll()
        self.myProfileActiveTab = .stats
        self.showEditProfile = false
    }
}
