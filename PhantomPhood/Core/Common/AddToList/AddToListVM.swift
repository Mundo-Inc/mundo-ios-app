//
//  AddToListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation

@MainActor
final class AddToListVM: ObservableObject {
    private let dataManager = ListsDM()
    private let auth = Authentication.shared
    private let toastManager = ToastViewModel.shared
    
    @Published var lists: [CompactUserPlacesList] = []
    @Published var selectedListIds: [String] = []
    @Published var isLoading: Bool = false
    
    @Published var isAddListPresented = false
    
    let placeId: String
    let dismiss: () -> Void
    
    init(placeId: String, dismiss: @escaping () -> Void) {
        self.placeId = placeId
        self.dismiss = dismiss
        
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = auth.currentUser?.id else { return }
        
        self.isLoading = true
        do {
            let data = try await dataManager.getUserLists(forUserId: uid)
            
            self.lists = data
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
    func submit() async {
        guard !selectedListIds.isEmpty else { return }
        
        self.isLoading = true
        for listId in selectedListIds {
            do {
                try await dataManager.addPlaceToList(listId: listId, placeId: placeId)
            } catch {
                print(error)
            }
        }
        toastManager.toast(.init(type: .success, title: "Added to List", message: "Place successfully added to lists"))
        self.isLoading = false
    }
    
    func selectList(listId: String) {
        if selectedListIds.contains(listId) {
            selectedListIds.removeAll(where: { $0 == listId })
        } else {
            selectedListIds.append(listId)
        }
    }
}
