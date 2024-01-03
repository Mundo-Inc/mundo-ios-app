//
//  EmojisVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import Foundation
import Combine

final class EmojisVM: ObservableObject {
    static let shared = EmojisVM()
    
    private var cancellables = Set<AnyCancellable>()
    
    /// The list of emojis. Observable to update the UI on changes.
    @Published
    private(set) var list: [EmojisManager.Emoji] = []
    
    /// The dictionary of emojis. Observable to update the UI on changes.
    /// The key is the emoji symbol.
    @Published
    private(set) var dict: [String:EmojisManager.Emoji] = [:]
    
    /// Private initializer to enforce singleton usage
    private init () {
        loadEmojis()
    }
    
    /// Initiates the loading of emoji data from `EmojisManager`.
    private func loadEmojis() {
        EmojisManager.getEmojisPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }, receiveValue: { [weak self] loadedEmojis in
                self?.list = loadedEmojis
                self?.dict = Dictionary(uniqueKeysWithValues: loadedEmojis.map { ($0.symbol, $0) })
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Returns an emoji for a given symbol
    /// - Parameter symbol: Emoji symbol
    /// - Returns: An emoji
    func getEmoji(forSymbol symbol: String) -> EmojisManager.Emoji? {
        return list.first(where: { $0.symbol == symbol })
    }

    /// Returns an array of emojis for a given keyword
    func getEmojis(keyword: String) -> [EmojisManager.Emoji] {
        return list.filter { $0.keywords.contains(keyword) }
    }

    /// Returns an array of emojis for a given category
    func getEmojis(category: EmojisManager.EmojiCategory) -> [EmojisManager.Emoji] {
        return list.filter { $0.categories.contains(category.rawValue) }
    }

    /// Returns an array of emojis for a given search term
    func getEmojis(searchTerm: String) -> [EmojisManager.Emoji] {
        return list.filter { $0.symbol.contains(searchTerm) || $0.title.contains(searchTerm) || $0.keywords.contains(searchTerm) || $0.categories.contains(searchTerm) }
    }
}
