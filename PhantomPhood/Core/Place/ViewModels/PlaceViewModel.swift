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
    private let id: String
    private let action: PlaceAction?
    
    private let dataManager = PlaceDataManager()
    private let toastViewModel = ToastViewModel.shared
    
    @Published var showActions: Bool = false
    
    @Published private(set) var isLoading = false
    @Published private(set) var place: Place?
    @Published private(set) var error: String?
    
    @Published var showAddReview = false
    
    @Published var activeTab: PlaceTab = .overview
    @Published var prevActiveTab: PlaceTab = .overview
    
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
    
    func fetchData() async {
        do {
            self.place = try await dataManager.fetch(id: id)
            self.error = nil
        } catch {
            print(error)
            self.error = error.localizedDescription
        }
    }
    
    func checkin() async {
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

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
