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
    
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var searchResults: [UserEssentials] = []
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
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
        } catch {
            presentErrorToast(error, silent: true)
        }
        self.isLoading = false
    }
}
