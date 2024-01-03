//
//  AddListCollaboratorVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/2/24.
//

import Foundation
import Combine

@MainActor
final class AddListCollaboratorVM: ObservableObject {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    let onSelect: (CompactUser) -> Void
    let onCancel: () -> Void
    
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var searchResults: [CompactUser] = []
    
    @Published var error: String? = nil
    private var cancellable = [AnyCancellable]()
    
    init(onSelect: @escaping (CompactUser) -> Void, onCancel: @escaping () -> Void) {
        self.onSelect = onSelect
        self.onCancel = onCancel
        
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
        guard let token = await auth.getToken() else { return }
        
        self.isLoading = true
        do {
            let data = try await self.apiManager.requestData("/users\(value.isEmpty ? "" : "?q=\(value)")", token: token) as APIResponse<[CompactUser]>?
            if let data {
                self.searchResults = data.data
            }
            self.isLoading = false
        } catch {
            if let error = error as? APIManager.APIError {
                self.isLoading = false
                switch error {
                case .serverError(let serverError):
                    self.error = serverError.message
                    break
                default:
                    self.error = "Unknown Error"
                    break
                }
            } else {
                self.error = "Unknown Error"
            }
        }
        self.isLoading = false
    }
}
