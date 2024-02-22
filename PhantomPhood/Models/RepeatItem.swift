//
//  RepeatItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/22/24.
//

import Foundation

/// A utility struct for generating unique, identifiable items, each associated with an index.
struct RepeatItem: Identifiable, Hashable {
    let id: UUID
    let index: Int
    
    /// Generates an array of `RepeatItem` instances, automatically assigning an index to each.
    /// - Parameter count: The number of items to generate.
    /// - Returns: An array of `RepeatItem`, each with a unique ID and an index.
    static func create(_ count: Int) -> [RepeatItem] {
        return (0..<count).map { RepeatItem(index: $0) }
    }
    
    /// Private initializer to enforce creation through static methods.
    private init(index: Int) {
        self.id = UUID()
        self.index = index
    }
}
