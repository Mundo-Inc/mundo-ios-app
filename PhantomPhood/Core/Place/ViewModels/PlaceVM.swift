//
//  PlaceVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import Foundation

@MainActor
final class PlaceVM: ObservableObject {
    private let placeDM = PlaceDM()
    
    @Published private(set) var place: PlaceDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    enum ScoresTab {
        case googlePhantomYelp
        case scores
        case map
    }
    
    @Published var scoresTabView: ScoresTab = .googlePhantomYelp
    
    @Published var presentedSheet: Sheets? = nil
    @Published var activeTab: PlaceTab = .media
    @Published var expandedMedia: MixedMedia? = nil
    
    @Published var draggedAmount: CGSize = .zero
    
    /// user's lists that include this place
    @Published var includedLists: [String]? = nil
    
    init(id: String, action: PlaceAction? = nil) {
        Task {
            await updateIncludedLists(id: id)
        }
        Task {
            do {
                let data = try await placeDM.fetch(id: id)
                self.place = data
                
                self.handleNavigationAction(place: data, action: action)
            } catch {
                print(error)
                self.error = error.localizedDescription
            }
        }
    }
    
    init(mapPlace: MapPlace, action: PlaceAction? = nil) {
        Task {
            do {
                let data = try await placeDM.fetch(mapPlace: mapPlace)
                self.place = data
                
                self.handleNavigationAction(place: data, action: action)
                
                await updateIncludedLists()
            } catch {
                print(error)
                self.error = error.localizedDescription
            }
        }
    }
    
    // MARK: - Public Methods
    
    func updateIncludedLists(id: String? = nil) async {
        guard let id = id ?? self.place?.id else { return }
        
        do {
            let listIds = try await placeDM.getIncludedLists(id: id)
            self.includedLists = listIds
        } catch {
            print(error)
            ToastVM.shared.toast(Toast(type: .error, title: "Failed to update lists", message: error.localizedDescription))
        }
    }
    
    // MARK: - Private Methods
    
    private func handleNavigationAction(place: PlaceDetail, action: PlaceAction?) {
        switch action {
        case .checkin:
            AppData.shared.goTo(AppRoute.checkin(.data(PlaceEssentials(placeDetail: place))))
        case .addReview:
            self.activeTab = .reviews
            AppData.shared.goTo(AppRoute.review(.data(PlaceEssentials(placeDetail: place))))
        case nil:
            break
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
