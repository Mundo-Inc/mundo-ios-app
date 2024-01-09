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
    let _id: String
    let reaction: String
    let type: ReactionType
    let createdAt: String
    
    var id: String {
        self._id
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
