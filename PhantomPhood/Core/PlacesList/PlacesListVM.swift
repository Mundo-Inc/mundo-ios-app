//
//  PlacesListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation

@MainActor
final class PlacesListVM: ObservableObject {
    private let listsDM = ListsDM()
    
    let listId: String
    
    @Published var tabViewSelection: Tabs = .list
    @Published var editingList: UserPlacesList? = nil
    @Published var list: UserPlacesList? = nil
    
    init(listId: String) {
        self.listId = listId
        
        Task {
            await getList()
        }
    }
    
    func deleteList() async {
        guard let list else { return }
        
        do {
            try await listsDM.deleteList(withId: list.id)
        } catch {
            presentErrorToast(error)
        }
    }
    
    func removePlaceFromList(placeId: String) async {
        guard let list else { return }
        do {
            try await listsDM.removePlaceFromList(listId: list.id, placeId: placeId)
            await self.getList()
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: Private methods
    
    private func getList() async {
        do {
            self.list = try await listsDM.getList(withId: self.listId)
        } catch {
            presentErrorToast(error)
        }
    }
    
    // MARK: Enums
    
    enum Tabs: String {
        case list = "list"
        case map = "map"
        
        var title: String {
            switch self {
            case .list:
                return "List"
            case .map:
                return "Map"
            }
        }
        
        var icon: String {
            switch self {
            case .list:
                return "list.bullet.circle"
            case .map:
                return "map"
            }
        }
        
        var iconSelected: String {
            switch self {
            case .list:
                return "list.bullet.circle.fill"
            case .map:
                return "map.fill"
            }
        }
    }
}
