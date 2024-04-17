//
//  MyProfileListsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation

@MainActor
final class MyProfileListsVM: ObservableObject {
    private let listsDM = ListsDM()
    private let auth = Authentication.shared
    
    @Published var lists: [CompactUserPlacesList] = []
    @Published var isLoading: Bool = false
    
    @Published var isAddListPresented = false
    
    init() {
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = auth.currentUser?.id else { return }
        
        self.isLoading = true
        do {
            let data = try await listsDM.getUserLists(forUserId: uid)
            
            self.lists = data
        } catch {
            presentErrorToast(error)
        }
        self.isLoading = false
    }
}
