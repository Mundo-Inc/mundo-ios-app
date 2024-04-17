//
//  AddListCollaboratorVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import Foundation
import Combine

@MainActor
final class UserSelectorVM: ObservableObject {
    private let searchDM = SearchDM()
    
    let onSelect: (UserEssentials) -> Void
    
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var searchResults: [UserEssentials] = []
    
    @Published var error: String? = nil
    private var cancellable = [AnyCancellable]()
    
    init(onSelect: @escaping (UserEssentials) -> Void) {
        self.onSelect = onSelect
        
        Task {
            await self.search("")
        }
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { value in
                Task {
                    await self.search(value)
                }
            }
            .store(in: &cancellable)
    }
    
    func search(_ value: String) async {
        self.isLoading = true
        do {
            let data = try await self.searchDM.searchUsers(q: value)
            self.searchResults = data
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.error = getErrorMessage(error)
        }
        self.isLoading = false
    }
}
