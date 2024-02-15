//
//  Prize.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/15/24.
//

import Foundation

struct Prize: Identifiable, Codable {
    let id: String
    let title: String
    let thumbnail: URL
    let amount: Int
    let createdAt: Date
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, thumbnail, amount, createdAt, count
    }
}
