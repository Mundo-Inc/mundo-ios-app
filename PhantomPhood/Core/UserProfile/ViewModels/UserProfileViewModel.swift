//
//  UserProfileViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    private let id: String
    
    private let dataManager = UserProfileDataManager()
    
    @Published private(set) var isLoading = false
    @Published private(set) var user: UserProfile?
    @Published private(set) var error: String?
    
    init(id: String) {
        self.id = id
        
        Task {
            await fetchUser()
        }
    }
    
    func fetchUser() async {
        do {
            self.user = try await dataManager.fetch(id: id)
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
