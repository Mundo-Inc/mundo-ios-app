//
//  UserStats.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/24/24.
//

import Foundation

struct UserStats: Decodable {
    let userActivityWithMediaCount: Int
    let gainedUniqueReactions: Int
    let rank: Int
    let dailyStreak: Int
}
