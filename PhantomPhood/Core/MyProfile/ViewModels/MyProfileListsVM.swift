//
//  MyProfileListsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation

@MainActor
final class MyProfileListsVM: ObservableObject {
    private let dataManager = ListsDM()
    private let auth = Authentication.shared
    
    @Published var lists: [CompactUserPlacesList] = []
    @Published var isLoading: Bool = false
    
    @Published var isAddListPresented = false
    
    init() {
        Task {
            await fetchLists(action: .refresh)
        }
    }
    
    func fetchLists(action: RefreshNewAction) async {
        guard let uid = auth.currentUser?.id else { return }
        
        self.isLoading = true
        do {
            let data = try await dataManager.getUserLists(forUserId: uid)
            
            switch action {
            case .refresh:
                self.lists = data
            case .new:
                self.lists.append(contentsOf: data)
            }
        } catch {
            print(error)
        }
        self.isLoading = false
    }
}
