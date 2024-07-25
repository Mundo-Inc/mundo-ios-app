//
//  RewardsHubVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI
import CoreData

final class RewardsHubVM: ObservableObject, LoadingSections {
    private let userProfileDM = UserProfileDM()
    private let rewardsDM = RewardsDM()
    
    @Published var showingHowItWorks: Bool = false
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published private(set) var stats: UserStats? = nil
    
    @Published private(set) var cashOutRequested = false
    
    func getStats() async {
        guard !loadingSections.contains(.fetchStats) else { return }
        
        setLoadingState(.fetchStats, to: true)
        
        defer {
            setLoadingState(.fetchStats, to: false)
        }
        
        do {
            let data = try await userProfileDM.getStats()
            await MainActor.run {
                self.stats = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func cashOut() async {
        guard !loadingSections.contains(.cashOut) else { return }
        
        setLoadingState(.cashOut, to: true)
        
        defer {
            setLoadingState(.cashOut, to: false)
        }
        
        HapticManager.shared.prepare()
        SoundManager.shared.prepare(sound: .coin)
        
        do {
            let res = try await rewardsDM.cashOut()
            
            ToastVM.shared.toast(.init(type: .success, title: "Success", message: res.message ?? "We got your request, We'll email you the details soon!"))
            
            HapticManager.shared.notification(type: .success)
            SoundManager.shared.playSound(.coin)
            
            await MainActor.run {
                self.cashOutRequested = true
            }
        } catch {
            presentErrorToast(error)
        }
    }
}

extension RewardsHubVM {
    enum LoadingSection: Hashable {
        case fetchStats
        case cashOut
    }
}
