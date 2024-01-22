//
//  PhantomCoins.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation

struct PhantomCoins: Codable {
    var balance: Int
    var daily: DailyRewards
    
    struct DailyRewards: Codable {
        var streak: Int
        let lastClaim: String?

        var lastClaimDate: Date? {
            guard let lastClaim else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter.date(from: lastClaim)
        }
    }
}
