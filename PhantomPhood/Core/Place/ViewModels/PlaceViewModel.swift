//
//  PlaceViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/1/23.
//

import Foundation
import MapKit
import SwiftUI

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
    private let toastViewModel = ToastViewModel.shared
    
    @Published var showActions: Bool = false
    
    @Published private(set) var isLoading = false
    @Published private(set) var place: Place?
    @Published private(set) var error: String?
    
    @Published var showAddReview = false
    
    @Published var activeTab: PlaceTab = .overview
    @Published var prevActiveTab: PlaceTab = .overview
    
    @Published var reportId: String? = nil

    
    init(id: String, action: PlaceAction? = nil) {
        self.id = id
        self.action = action
        
        switch action {
        case .checkin:
            Task {
                await self.checkin()
            }
        case .addReview:
            self.activeTab = .reviews
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAddReview = true
            }
        case nil:
            break
        }
        
        Task {
            await self.fetchData()
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
                    Task {
                        await self.checkin()
                    }
                case .addReview:
                    self.activeTab = .reviews
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showAddReview = true
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
    
//    init(mapItem: MKMapItem, action: PlaceAction? = nil) {
//        self.action = action
//        
//        Task {
//            do {
//                let data = try await dataManager.fetch(mapItem: mapItem)
//                self.id = data.id
//                self.place = data
//                
//                switch action {
//                case .checkin:
//                    Task {
//                        await self.checkin()
//                    }
//                case .addReview:
//                    self.activeTab = .reviews
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.showAddReview = true
//                    }
//                case nil:
//                    break
//                }
//            } catch {
//                print(error)
//                self.error = error.localizedDescription
//            }
//        }
//    }
//    
//    @available(iOS 17.0, *)
//    init(mapFeature: MapFeature, action: PlaceAction? = nil) {
//        self.action = action
//        
//        Task {
//            do {
//                let data = try await dataManager.fetch(mapFeature: mapFeature)
//                self.id = data.id
//                self.place = data
//                
//                switch action {
//                case .checkin:
//                    Task {
//                        await self.checkin()
//                    }
//                case .addReview:
//                    self.activeTab = .reviews
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.showAddReview = true
//                    }
//                case nil:
//                    break
//                }
//            } catch {
//                print(error)
//                self.error = error.localizedDescription
//            }
//        }
//    }
    
    func fetchData() async {
        if let id {
            do {
                self.place = try await dataManager.fetch(id: id)
                self.error = nil
            } catch {
                print(error)
                self.error = error.localizedDescription
            }
        }
    }
    
    func checkin() async {
        if let id {
            do {
                try await dataManager.checkin(id: id)
                toastViewModel.toast(Toast(type: .success, title: "Checkin", message: "Checked in successfully"))
            } catch {
                print(error)
                self.error = error.localizedDescription
                toastViewModel.toast(Toast(type: .error, title: "Checkin", message: "Failed to checkin"))
            }
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
