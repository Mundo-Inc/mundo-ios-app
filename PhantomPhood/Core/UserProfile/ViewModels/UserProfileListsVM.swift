//
//  UserProfileListsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/4/24.
//

import Foundation

@MainActor
final class UserProfileListsVM: ObservableObject {
    private let listsDM = ListsDM()
    private let auth = Authentication.shared
    
    @Published var lists: [CompactUserPlacesList] = []
    @Published var isLoading: Bool = false
    
    @Published var isAddListPresented = false
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard !isLoading else { return }
        
        self.isLoading = true
        do {
            let data = try await listsDM.getUserLists(forUserId: self.userId)
            
            self.lists = data
        } catch {
            presentErrorToast(error)
        }
        self.isLoading = false
    }
}
