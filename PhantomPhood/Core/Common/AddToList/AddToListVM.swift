//
//  AddToListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation
import SwiftUI

@MainActor
final class AddToListVM: ObservableObject {
    private let listsDM = ListsDM()
    private let toastManager = ToastVM.shared
    private let placeVM: PlaceVM
    
    @Published var lists: [CompactUserPlacesList]? = nil
    @Published var actionsList: [ActionItem] = []
    @Published var isLoading: Bool = false
    
    @Published var isAddListPresented = false
    
    init(placeVM: PlaceVM) {
        self.placeVM = placeVM
        
        Task {
            await fetchLists()
        }
    }
    
    func fetchLists() async {
        guard let uid = Authentication.shared.currentUser?.id else { return }
        
        self.isLoading = true
        do {
            self.lists = try await listsDM.getUserLists(forUserId: uid)
        } catch {
            presentErrorToast(error)
        }
        self.isLoading = false
    }
    
    func submit() async {
        guard let placeId = placeVM.place?.id, !actionsList.isEmpty else { return }
        
        self.isLoading = true
        for item in actionsList {
            do {
                switch item.action {
                case .add:
                    try await listsDM.addPlaceToList(listId: item.id, placeId: placeId)
                case .remove:
                    try await listsDM.removePlaceFromList(listId: item.id, placeId: placeId)
                }
            } catch {
                presentErrorToast(error)
            }
        }
        HapticManager.shared.notification(type: .success)
        toastManager.toast(.init(type: .success, title: "Success", message: "Lists updated successfully"))
        self.isLoading = false
        withAnimation {
            self.placeVM.presentedSheet = nil
        }
        await self.placeVM.updateIncludedLists()
    }
    
    func addAction(item: ActionItem) {
        if actionsList.contains(where: { $0.id == item.id }) {
            actionsList.removeAll(where: { $0.id == item.id })
        } else {
            actionsList.append(item)
        }
    }
    
    func isItemSelected(includedLists: [String], listId: String) -> Bool {
        if let found = self.actionsList.first(where: { $0.id == listId }) {
            if found.action == .add {
                return true
            }
        } else if includedLists.contains(where: { $0 == listId }) {
            return true
        }
        return false
    }
    
    struct ActionItem {
        let id: String
        let action: ActionType
        
        enum ActionType {
            case add
            case remove
        }
    }
}
