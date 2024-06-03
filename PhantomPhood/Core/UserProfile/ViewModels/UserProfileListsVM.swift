//
//  UserProfileListsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/4/24.
//

import Foundation

final class UserProfileListsVM: ObservableObject {
    private let listsDM = ListsDM()
    private let auth = Authentication.shared
    
    @Published private(set) var lists: [CompactUserPlacesList] = []
    @Published private(set) var loadingSections = Set<LoadingSection>()
    
    @Published var isAddListPresented = false
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard !loadingSections.contains(.fetchLists) else { return }
        
        await updateLoadingState(.fetchLists, to: true)
        do {
            let data = try await listsDM.getUserLists(forUserId: self.userId)
            await setLists(data)
        } catch {
            presentErrorToast(error)
        }
        await updateLoadingState(.fetchLists, to: false)
    }
    
    // MARK: Private methods
    
    @MainActor
    private func updateLoadingState(_ section: LoadingSection, to isLoading: Bool) {
        if isLoading {
            self.loadingSections.insert(section)
        } else {
            self.loadingSections.remove(section)
        }
    }
    
    @MainActor
    private func setLists(_ data: [CompactUserPlacesList]) {
        self.lists = data
    }
    
    // MARK: Enums
    
    enum LoadingSection: Hashable {
        case fetchLists
    }
}
