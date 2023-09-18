//
//  AppData.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

class AppData: ObservableObject {
    @Published var activeTab: Tab = .home
    
    @Published var homeNavStack: [HomeStack] = []
    @Published var mapNavStack: [MapStack] = []
    @Published var leaderboardNavStack: [LeaderboardStack] = []
    @Published var authNavStack: [AuthStack] = []
    
    // My Profile Tab
    @Published var myProfileNavStack: [MyProfileStack] = []
    @Published var myProfileActiveTab: MyProfileActiveTab = .stats
    @Published var showEditProfile: Bool = false
}
