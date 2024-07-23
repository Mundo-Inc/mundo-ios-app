//
//  MediaItemsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import Foundation
import Combine

@MainActor
final class MediaItemsVM: ObservableObject {
    @Published var show = false
    @Published var items: [MediaItem] = []
        
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $show
            .sink { newValue in
                if !newValue {
                    self.items.removeAll()
                }
            }
            .store(in: &cancellables)
    }
    
    func show(_ items: [MediaItem]) {
        self.items = items
        self.show = true
    }
}
