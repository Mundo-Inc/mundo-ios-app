//
//  Mission.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/19/24.
//

import Foundation

struct Mission: Identifiable, Codable {
    let id: String
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
    
    struct MissionTask: Codable {
        let type: String
        let count: Int
    }
    struct MissionProgress: Codable {
        let completed: Int
        let total: Int
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, subtitle, icon, rewardAmount, startsAt, expiresAt, createdAt, isClaimed, task, progress
    }
}
