//
//  ClusteredMapActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/28/24.
//

import Foundation

struct ClusteredMapActivity: Identifiable, Hashable {
    let id: String
    let event: Event?
    let items: [MapActivity]
    
    init(items: [MapActivity], event: Event? = nil) {
        self.id = items.first?.place.id ?? UUID().uuidString
        self.items = items
        self.event = event
    }
    
    var first: MapActivity? {
        return items.first
    }
    
    static func == (lhs: ClusteredMapActivity, rhs: ClusteredMapActivity) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        items.forEach { hasher.combine($0.id) }
    }
}
