//
//  EmojiesVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import Foundation
import Combine

final class EmojiesVM: ObservableObject {
    static let shared = EmojiesVM()
    
    private var cancellables = Set<AnyCancellable>()
    
    /// The list of emojis. Observable to update the UI on changes.
    @Published
    private(set) var list: [EmojiesManager.Emoji] = []
    
    /// The dictionary of emojis. Observable to update the UI on changes.
    /// The key is the emoji symbol.
    @Published
    private(set) var dict: [String:EmojiesManager.Emoji] = [:]
    
    /// Private initializer to enforce singleton usage
    private init () {
        loadEmojies()
    }
    
    /// Initiates the loading of emoji data from `EmojiesManager`.
    private func loadEmojies() {
        EmojiesManager.getEmojiesPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }, receiveValue: { [weak self] loadedEmojies in
                self?.list = loadedEmojies
                self?.dict = Dictionary(uniqueKeysWithValues: loadedEmojies.map { ($0.symbol, $0) })
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Returns an emoji for a given symbol
    /// - Parameter symbol: Emoji symbol
    /// - Returns: An emoji
    func getEmoji(forSymbol symbol: String) -> EmojiesManager.Emoji? {
        return list.first(where: { $0.symbol == symbol })
    }

    /// Returns an array of emojies for a given keyword
    func getEmojies(keyword: String) -> [EmojiesManager.Emoji] {
        return list.filter { $0.keywords.contains(keyword) }
    }

    /// Returns an array of emojies for a given category
    func getEmojies(category: EmojiesManager.EmojiCategory) -> [EmojiesManager.Emoji] {
        return list.filter { $0.categories.contains(category.rawValue) }
    }

    /// Returns an array of emojies for a given search term
    func getEmojies(searchTerm: String) -> [EmojiesManager.Emoji] {
        return list.filter { $0.symbol.contains(searchTerm) || $0.title.contains(searchTerm) || $0.keywords.contains(searchTerm) || $0.categories.contains(searchTerm) }
    }
}
