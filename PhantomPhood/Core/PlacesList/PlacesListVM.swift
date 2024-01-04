//
//  PlacesListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import Foundation

@MainActor
final class PlacesListVM: ObservableObject {
    private let dataManager = ListsDM()
    
    let listId: String
    
    @Published var tabViewSelection: Tabs = .list
    
    @Published var deleteListConfirmation: Bool = false
    
    @Published var removePlaceConfirmation: Bool = false
    var removePlaceId: String? = nil
    
    @Published var list: UserPlacesList? = nil
    
    init(listId: String) {
        self.listId = listId
        
        Task {
            await getList()
        }
    }
    
    private func getList() async {
        do {
            let data = try await dataManager.getList(withId: self.listId)
            self.list = data
        } catch {
            print(error)
        }
    }
    
    func deleteList() async {
        if let list = self.list {
            do {
                try await dataManager.deleteList(withId: list.id)
                await self.getList()
            } catch {
                print(error)
            }
        }
    }
    
    func deletePlaceFromList() async {
        if let list = self.list, let deleteId = self.removePlaceId {
            do {
                try await dataManager.removePlaceFromList(listId: list.id, placeId: deleteId)
                await self.getList()
            } catch {
                print(error)
            }
        }
    }
    
    func askRemovePlaceConfirmation(placeId: String) {
        self.removePlaceId = placeId
        self.removePlaceConfirmation = true
    }
    
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
