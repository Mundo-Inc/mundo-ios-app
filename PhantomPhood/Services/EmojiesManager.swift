//
//  EmojiesManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/19/23.
//

import Foundation
import Combine

final class EmojiesManager {
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
    ///     - `EmojiError.fileNotFound`: Indicates that the "emojies.json" file could not be found in the main bundle.
    ///     - `EmojiError.decodingFailed`: Indicates an error occurred during the decoding of the JSON data into `Emoji` objects.
    static func getEmojiesPublisher() -> AnyPublisher<[Emoji], Error> {
        Future<[Emoji], Error> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let url = Bundle.main.url(forResource: "emojies", withExtension: "json") else {
                    return promise(.failure(EmojiError.fileNotFound))
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let emojies = try decoder.decode([Emoji].self, from: data)
                    promise(.success(emojies))
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
