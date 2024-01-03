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
    @Published var onSelect: ((_ reaction: EmojisManager.Emoji) -> Void)? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Try to use `shared` instance instead of creating new one when possible.
    /// If using inside of a sheet, create new instance and use it.
    init() {
        $isPresented
            .sink { newValue in
                if !newValue {
                    self.onSelect = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func select(onSelect: @escaping (_ reaction: EmojisManager.Emoji) -> Void) {
        self.onSelect = onSelect
        self.isPresented = true
    }
}
