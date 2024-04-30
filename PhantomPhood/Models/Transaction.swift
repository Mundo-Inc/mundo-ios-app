//
//  Transaction.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/30/24.
//

import Foundation

struct Transaction: Identifiable, Decodable {
    let id: String
    let amount: Double
    let sender: UserEssentials
    let receiver: UserEssentials
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount, sender, receiver, createdAt
    }
}
