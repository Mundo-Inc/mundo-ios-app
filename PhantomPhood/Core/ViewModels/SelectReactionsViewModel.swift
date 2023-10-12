//
//  SelectReactionsViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import Foundation
import Combine

@MainActor
class SelectReactionsViewModel: ObservableObject {
    static let shared = SelectReactionsViewModel()
    
    @Published var isPresented = false
    @Published var onSelect: ((_ reaction: NewReaction) -> Void)? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $isPresented
            .sink { newValue in
                if !newValue {
                    self.onSelect = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func select(onSelect: @escaping (_ reaction: NewReaction) -> Void) {
        self.onSelect = onSelect
        self.isPresented = true
    }
}
