//
//  PhantomCoinsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation
import SwiftUI

@MainActor
final class PhantomCoinsVM: ObservableObject {
    static let shared = PhantomCoinsVM()
    static let BalanceIncreaseSteps: Int = 10
    
    private let rewardsDM = RewardsDM()
    
    /// Source of truth
    private var phantomCoins: PhantomCoins? = nil
    
    @Published var balance: Int? = nil
    @Published var streaks: Int? = nil
    @Published var dailyRewards: [Int]? = nil
    
    @Published var isLoading = false
    
    private init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        self.isLoading = true
        do {
            let data = try await rewardsDM.getDailyRewardsInfo()
            let oldPhantomCoins = phantomCoins
            phantomCoins = data.phantomCoins
            dailyRewards = data.dailyRewards
            
            if let phantomCoins = oldPhantomCoins {
                if phantomCoins.balance < data.phantomCoins.balance {
                    let difference = data.phantomCoins.balance - phantomCoins.balance
                    if difference >= 10 {
                        let diff = Int(difference / PhantomCoinsVM.BalanceIncreaseSteps)
                        for i in 1...PhantomCoinsVM.BalanceIncreaseSteps {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i*3) * 0.02) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                if i == PhantomCoinsVM.BalanceIncreaseSteps {
                                    self.balance = data.phantomCoins.balance
                                } else {
                                    self.balance = phantomCoins.balance + i * diff
                                    if i == 1 {
                                        SoundManager.shared.playSound(.coin)
                                    }
                                }
                            }
                        }
                    } else {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        self.balance = data.phantomCoins.balance
                        SoundManager.shared.playSound(.coin)
                    }
                }
            } else {
                self.balance = data.phantomCoins.balance
            }
            
            self.streaks = data.phantomCoins.daily.streak
        } catch {
            print(error)
        }
        self.isLoading = false
    }

    var hasClaimedToday: Bool {
        guard let lastClaimDate = phantomCoins?.daily.lastClaimDate else { return false }
        return Date().timeIntervalSince(lastClaimDate) < 24 * 60 * 60
    }

    var nextClaimDate: Date? {
        guard let lastClaimDate = phantomCoins?.daily.lastClaimDate else { return nil }
        return lastClaimDate.addingTimeInterval(24 * 60 * 60)
    }
}
