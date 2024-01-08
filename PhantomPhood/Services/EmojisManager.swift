//
//  EmojisManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import Foundation
import Combine

final class EmojisManager {
    struct Emoji: Identifiable, Hashable, Equatable, Decodable {
        let symbol: String
        let title: String
        let keywords: [String]
        let categories: [String]
        let isAnimated: Bool
        let unicode: String
        
        var id: String {
            self.symbol
        }
        var gifName: String? {
            return self.isAnimated ? self.unicode + ".gif" : nil
        }
        
        init(symbol: String, title: String, keywords: [String], categories: [String], isAnimated: Bool, unicode: String) {
            self.symbol = symbol
            self.title = title
            self.keywords = keywords
            self.categories = categories
            self.isAnimated = isAnimated
            self.unicode = unicode
        }
        
        init(symbol: String) {
            let theEmoji = EmojisVM.shared.getEmoji(forSymbol: symbol)
            if let theEmoji {
                self = theEmoji
            } else {
                self = .init(symbol: symbol, title: "", keywords: [], categories: [], isAnimated: false, unicode: "")
            }
        }
    }
    
    enum EmojiCategory: String, CaseIterable {
        case common = "common"
        case foods = "foods"
        case drinks = "drinks"
        case faces = "faces"
        case flags = "flags"
        
        var icon: String {
            switch self {
            case .common:
                "star.square.on.square.fill"
            case .foods:
                "fork.knife.circle.fill"
            case .drinks:
                "wineglass.fill"
            case .faces:
                "face.smiling"
            case .flags:
                "flag.fill"
            }
        }
    }
    
    /// Fetches emoji data asynchronously using a Combine publisher.
    ///
    /// - Returns: An `AnyPublisher` that emits an array of `Emoji` objects, or an `Error`.
    ///            The publisher will run its work on a background thread and return results on the main thread.
    ///
    /// - Error Handling:
    ///     - `EmojiError.fileNotFound`: Indicates that the "emojis.json" file could not be found in the main bundle.
    ///     - `EmojiError.decodingFailed`: Indicates an error occurred during the decoding of the JSON data into `Emoji` objects.
    static func getEmojisPublisher() -> AnyPublisher<[Emoji], Error> {
        Future<[Emoji], Error> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let url = Bundle.main.url(forResource: "emojis", withExtension: "json") else {
                    return promise(.failure(EmojiError.fileNotFound))
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let emojis = try decoder.decode([Emoji].self, from: data)
                    promise(.success(emojis))
                } catch {
                    promise(.failure(EmojiError.decodingFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Enum representing errors that can be encountered in the emoji loading process.
    enum EmojiError: Error {
        case fileNotFound
        case decodingFailed
    }
}
