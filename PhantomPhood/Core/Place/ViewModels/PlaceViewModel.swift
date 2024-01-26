//
//  PlaceViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation
import MapKit

enum PlaceTab: String, CaseIterable, Hashable {
    case overview = "Overview"
    case reviews = "Reviews"
    case media = "Media"
}

@MainActor
class PlaceViewModel: ObservableObject {
    private(set) var id: String? = nil
    private let action: PlaceAction?
    
    private let dataManager = PlaceDM()
    private let toastViewModel = ToastVM.shared
    private let appData = AppData.shared
    
    @Published var isMapNavigationPresented: Bool = false
    @Published var isAddToListPresented: Bool = false
    
    @Published private(set) var isLoading = false
    @Published private(set) var place: PlaceDetail?
    @Published private(set) var error: String?
    
    @Published var activeTab: PlaceTab = .overview
    @Published var prevActiveTab: PlaceTab = .overview
    
    @Published var reportId: String? = nil
    
    
    init(id: String, action: PlaceAction? = nil) {
        self.id = id
        self.action = action
        
        Task {
            do {
                let data = try await dataManager.fetch(id: id)
                self.place = data
                
                switch action {
                case .checkin:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.appData.goTo(AppRoute.checkin(.data(PlaceEssentials(placeDetail: data))))
                    }
                case .addReview:
                    self.activeTab = .reviews
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.appData.goTo(AppRoute.review(.data(PlaceEssentials(placeDetail: data))))
                    }
                case nil:
                    break
                }
            } catch {
                print(error)
                self.error = error.localizedDescription
            }
        }
    }
    
    init(mapPlace: MapPlace, action: PlaceAction? = nil) {
        self.action = action
        
        Task {
            do {
                let data = try await dataManager.fetch(mapPlace: mapPlace)
                self.id = data.id
                self.place = data
                
                switch action {
                case .checkin:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.appData.goTo(AppRoute.checkin(.data(PlaceEssentials(placeDetail: data))))
                    }
                case .addReview:
                    self.activeTab = .reviews
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.appData.goTo(AppRoute.review(.data(PlaceEssentials(placeDetail: data))))
                    }
                case nil:
                    break
                }
            } catch {
                print(error)
                self.error = error.localizedDescription
            }
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
