//
//  PlaceVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import Foundation

final class PlaceVM: ObservableObject {
    private let placeDM = PlaceDM()
    
    @Published private(set) var place: PlaceDetail?
    
    enum ScoresTab {
        case googlePhantomYelp
        case scores
        case map
    }
    
    @Published var scoresTabView: ScoresTab = .googlePhantomYelp
    
    @Published var presentedSheet: Sheets? = nil
    @Published var activeTab: PlaceTab = .media
    @Published var expandedMedia: MediaItem? = nil
    
    @Published var draggedAmount: CGSize = .zero
    
    /// user's lists that include this place
    @Published var includedLists: [String]? = nil
    
    init(data: PlaceDetail, action: PlaceAction?) {
        self.place = data
        self.handleNavigationAction(place: data, action: action)
        
        Task {
            await updateIncludedLists(id: data.id)
        }
    }
    
    init(id: String, action: PlaceAction?) {
        Task {
            await updateIncludedLists(id: id)
        }
        Task {
            do {
                let data = try await placeDM.fetch(id: id)
                
                await MainActor.run {
                    self.place = data
                }
                
                self.handleNavigationAction(place: data, action: action)
            } catch {
                presentErrorToast(error)
            }
        }
    }
    
    init(mapPlace: MapPlace, action: PlaceAction?) {
        Task {
            do {
                let data = try await placeDM.fetch(mapPlace: mapPlace)
                
                await MainActor.run {
                    self.place = data
                }
                
                self.handleNavigationAction(place: data, action: action)
                
                await updateIncludedLists()
            } catch {
                presentErrorToast(error)
            }
        }
    }
    
    // MARK: - Public Methods
    
    func updateIncludedLists(id: String? = nil) async {
        guard let id = id ?? self.place?.id else { return }
        
        do {
            let listIds = try await placeDM.getIncludedLists(id: id)
            
            await MainActor.run {
                self.includedLists = listIds
            }
        } catch {
            presentErrorToast(error, title: "Failed to update lists")
        }
    }
    
    // MARK: - Private Methods
    
    private func handleNavigationAction(place: PlaceDetail, action: PlaceAction?) {
        guard let action else { return }
        
        switch action {
        case .checkIn:
            AppData.shared.goTo(AppRoute.checkIn(.detail(place)))
        }
    }
    
    // MARK: - Enums
    
    enum Sheets {
        case navigationOptions
        case addToList
        case openningHours
    }
}

enum PlaceTab: String, CaseIterable, Hashable {
    case reviews = "Reviews"
    case media = "Media"
}
