//
//  EmojisVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/18/23.
//

import Foundation

final class EmojisVM {
    struct Emoji: Identifiable, Hashable, Equatable, Decodable {
        let symbol: String
        let title: String
        let keywords: [String]
        let categories: [String]
        
        var id: String {
            self.symbol
        }
    }

    /// Returns an array of all emojis
    static let emojis: [Emoji] = {
        guard let url = Bundle.main.url(forResource: "emojis", withExtension: "json") else {
            fatalError("emojis.json not found")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let emojis = try decoder.decode([Emoji].self, from: data)
            return emojis
        } catch {
            fatalError("emojis.json decoding failed")
        }
    }()

    /// Returns an emoji for a given symbol
    static func getEmoji(for symbol: String) -> Emoji? {
        return emojis.first(where: { $0.symbol == symbol })
    }
}
