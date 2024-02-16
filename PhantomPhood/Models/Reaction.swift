//
//  Reaction.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

enum ReactionType: String, Decodable {
    case emoji = "emoji"
    case special = "special"
}

struct Reaction: Decodable, Identifiable, GeneralReactionProtocol {
    let reaction: String
    let type: ReactionType
    let count: Int

    var id: String {
        reaction + String(count) + type.rawValue
    }
}

struct UserReaction: Identifiable, Decodable, GeneralReactionProtocol {
    let id: String
    let reaction: String
    let type: ReactionType
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reaction, type, createdAt
    }
}

struct NewReaction: Decodable, Identifiable, GeneralReactionProtocol {
    let reaction: String
    let type: ReactionType

    var id: String {
        reaction + type.rawValue
    }
}

protocol GeneralReactionProtocol {
    var reaction: String { get }
    var type: ReactionType { get }
}
