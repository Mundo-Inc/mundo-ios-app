//
//  Mission.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation

struct Mission: Identifiable, Codable {
    let _id: String
    let title: String
    let subtitle: String?
    let icon: String
    let rewardAmount: Int
    let startsAt: String
    let expiresAt: String
    let createdAt: String
    var isClaimed: Bool
    let task: MissionTask
    let progress: MissionProgress
    
    var id: String {
        self._id
    }
    
    struct MissionTask: Codable {
        let type: String
        let count: Int
    }
    struct MissionProgress: Codable {
        let completed: Int
        let total: Int
    }
}
