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
    
    // Leaderboard Tab
    @Published var leaderboardNavStack: [AppRoute] = []
    
    // Home Tab
    @Published var homeNavStack: [AppRoute] = []
    @Published var homeActiveTab: HomeTab = .forYou
    
    // My Profile Tab
    @Published var myProfileNavStack: [AppRoute] = []
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
                case .explore:
                    if !self.exploreNavStack.isEmpty {
                        self.exploreNavStack.removeLast()
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
        self.exploreNavStack.removeAll()
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
        case .explore:
            self.exploreNavStack.append(.userProfile(userId: id))
        case .leaderboard:
            self.leaderboardNavStack.append(.userProfile(userId: id))
        case .myProfile:
            self.myProfileNavStack.append(.userProfile(userId: id))
        }
    }
    
    func visiblePlaceId() -> String? {
        switch self.activeTab {
        case .home:
            if let route = self.homeNavStack.last {
                switch route {
                case .place(let placeId, _):
                    return placeId
                default:
                    return nil
                }
            }
        case .explore:
            if let route = self.exploreNavStack.last {
                switch route {
                case .place(let placeId, _):
                    return placeId
                default:
                    return nil
                }
            }
        case .leaderboard:
            if let route = self.leaderboardNavStack.last {
                switch route {
                case .place(let placeId, _):
                    return placeId
                default:
                    return nil
                }
            }
        case .myProfile:
            if let route = self.myProfileNavStack.last {
                switch route {
                case .place(let placeId, _):
                    return placeId
                default:
                    return nil
                }
            }
        }
        return nil
    }
}

enum HomeTab: String {
    case forYou = "For You"
    case followings = "Followings"
}
