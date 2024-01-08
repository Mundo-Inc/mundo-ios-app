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
    
    @Published var showActions: Bool = false
    @Published var confirmationRequest: ConfirmationRequest? = nil
    @Published var editingList: UserPlacesList? = nil
        
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
            } catch {
                print(error)
            }
        }
    }
    
    func removePlaceFromList(placeId: String) async {
        if let list = self.list {
            do {
                try await dataManager.removePlaceFromList(listId: list.id, placeId: placeId)
                await self.getList()
            } catch {
                print(error)
            }
        }
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
    
    enum ConfirmationRequest: Equatable {
        case deleteList
        case deletePlace(String)
        
        static func == (lhs: ConfirmationRequest, rhs: ConfirmationRequest) -> Bool {
            switch (lhs, rhs) {
            case (.deleteList, .deleteList):
                return true
            case (.deletePlace(_), .deletePlace(_)):
                return true
            default:
                return false
            }
        }
    }
}
