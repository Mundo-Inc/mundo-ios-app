//
//  SelectReactionsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation
import Combine

@MainActor
final class SelectReactionsVM: ObservableObject {
    static let shared = SelectReactionsVM()
    
    @Published var isPresented = false
    @Published var onSelect: ((_ reaction: EmojiesManager.Emoji) -> Void)? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        $isPresented
            .sink { newValue in
                if !newValue {
                    self.onSelect = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func select(onSelect: @escaping (_ reaction: EmojiesManager.Emoji) -> Void) {
        self.onSelect = onSelect
        self.isPresented = true
    }
}
