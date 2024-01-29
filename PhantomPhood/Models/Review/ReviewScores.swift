//
//  ReviewScores.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

struct ReviewScores: Decodable {
    let overall: Double?
    let drinkQuality: Double?
    let foodQuality: Double?
    let atmosphere: Double?
    let service: Double?
    let value: Double?
}
