//
//  ExploreVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreData
import BranchSDK
import Combine

@available(iOS 17.0, *)
final class ExploreVM17: ObservableObject {
    private static let intersectionThreshold: Double = 0.5
    private static let cachedRegionExpirySeconds: Double = 90
    
    // MARK: - Shared
    
    private let auth = Authentication.shared
    private let dataStack = DataStack.shared
    private let eventsDM = EventsDM()
    private let mapDM = MapDM()
    
    @Published var events: [Event]? = nil
    
    @Published var showSet = Set<String>()
    @Published var activities: [MapActivity] = []
    
    @Published private(set) var loadingSections = Set<LoadingSection>()
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    @Published var isSearching: Bool = false
    @Published var startDate: DateOption = .month
    @Published var activitiesScope: MapDM.Scope = .global
    
    private var throttles = Set<Throttles>()

    // MARK: - Exclusive
    
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published private(set) var scale: CGFloat = 1
    
    private(set) var originalItems: [MapActivity] = []
    private(set) var fetchedAreas: [AreaLevel:[FetchedMapRect]] = [
        .A: [],
        .B: [],
        .C: [],
    ]
    
    private var nextUpdateContext: MapCameraUpdateContext?
    
    private var cancellables = [AnyCancellable]()
    
    init() {
        updateFetchedRegions()
        
        $startDate
            .sink { value in
                self.getSavedData(startDate: value.getDate)
                self.removeRequestedRegions()
            }
            .store(in: &cancellables)
        
        Task {
            await getEvents()
        }
    }
    
    // MARK: - Shared Methods
    
    func panToRegion(_ region: MKCoordinateRegion) {
        position = .region(region)
    }
    
    // MARK: - Exclusive Methods
    
    func fetchData(rect: MKMapRect) async {
        let areaLevel = AreaLevel.categorizeArea(rect.width * rect.height)
        let fetchRect = getMapRect(rect: rect, areaLevel: areaLevel)
        
        guard let intersectingRects = shouldFetch(rect: fetchRect, areaLevel: areaLevel) else { return }
        
        DispatchQueue.main.async {
            self.loadingSections.insert(.fetchActivities)
        }
        
        do {
            let ne = MKMapPoint(x: fetchRect.maxX, y: fetchRect.minY)
            let sw = MKMapPoint(x: fetchRect.minX, y: fetchRect.maxY)
            
            let data = try await mapDM.getMapActivities(ne: ne.coordinate, sw: sw.coordinate, startDate: startDate.getDate, scope: self.activitiesScope)
            
            saveActivites(data)
            addFetchedRect(fetchRect, areaLevel: areaLevel, intersectingRects: intersectingRects)
        } catch {
            print("Error", error)
        }
        
        DispatchQueue.main.async {
            self.loadingSections.remove(.fetchActivities)
        }
    }
    
    func getInviteLink() {
        guard !loadingSections.contains(.inviteLink) else { return }
                
        if let currentUser = auth.currentUser {
            self.loadingSections.insert(.inviteLink)
            HapticManager.shared.impact(style: .light)
            
            let buo: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "signup/\(currentUser.id)")
            buo.title = "Join \(currentUser.name) on Phantom Phood"
            buo.contentDescription = "You've been invited by \(currentUser.name) to Phantom Phood. Join friends in your dining experiences."
            
            if let profileImage = currentUser.profileImage {
                buo.imageUrl = profileImage.absoluteString
            } else {
                buo.imageUrl = "https://phantomphood.ai/img/NoProfileImage.jpg"
            }
            
            let lp: BranchLinkProperties = BranchLinkProperties()
            lp.feature = "referral"
            
            if let topViewController = UIApplication.shared.topViewController() {
                buo.showShareSheet(with: lp, andShareText: "Join \(currentUser.name) on Phantom Phood", from: topViewController) { (activityType, completed, error) in
                    if let error {
                        print(error)
                    } else {
                        self.loadingSections.remove(.inviteLink)
                        if completed {
                            if let url = URL(string: buo.getShortUrl(with: lp) ?? "") {
                                self.addInviteLink(url)
                            }
                        }
                    }
                }
            } else {
                self.loadingSections.remove(.inviteLink)
            }
        }
    }
    
    /// Used for updating annotations on demand
    private var latestMapContext: MapCameraUpdateContext?
    func onMapCameraChangeHandler(_ context: MapCameraUpdateContext) {
        self.latestMapContext = context
        DispatchQueue.main.async {
            self.scale = context.scaleValue
        }
        
        if !throttles.contains(.fetch) && !loadingSections.contains(.fetchActivities) {
            throttles.insert(.fetch)
            
            Task {
                await self.fetchData(rect: context.rect)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.throttles.remove(.fetch)
            }
        }
        
        guard !throttles.contains(.display) else {
            self.nextUpdateContext = context
            return
        }
        
        throttles.insert(.display)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.throttles.remove(.display)
            if let context = self.nextUpdateContext {
                DispatchQueue.global(qos: .userInitiated).async {
                    var newItems = self.originalItems.filter({ context.rect.contains(.init($0.place.coordinates)) })
                    if newItems.count > 50 {
                        newItems = Array(newItems.prefix(50))
                    }
                    DispatchQueue.main.async {
                        self.activities = newItems
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func addInviteLink(_ link: URL) {
        let context = UserDataStack.shared.viewContext
        let inviteLink = InviteLinkEntity(context: context)
        inviteLink.link = link
        inviteLink.createdAt = .now
        
        UserSettings.shared.inviteCredits -= 1
        
        do {
            try UserDataStack.shared.saveContext()
        } catch {
            print(error)
        }
    }
    
    private func addFetchedRect(_ rect: MKMapRect, areaLevel: AreaLevel, intersectingRects: [FetchedMapRect]) {
        let unitRects = devideRect(rect: rect, areaLevel: areaLevel).filter { r in
            !intersectingRects.contains { fetchedMapRegion in
                fetchedMapRegion.rect.midX == r.midX && fetchedMapRegion.rect.midY == r.midY
            }
        }
        
        for item in unitRects {
            let entity = RequestedRegionEntity(context: dataStack.viewContext)
            entity.x = item.origin.x
            entity.y = item.origin.y
            entity.width = item.width
            entity.height = item.height
            entity.savedAt = .now
            
            do {
                try dataStack.viewContext.obtainPermanentIDs(for: [entity])
            } catch {
                print("Error saving new RequestedRegionEntity", error)
            }
        }
        
        do {
            try dataStack.saveContext()
        } catch {
            print("Error saving new RequestedRegionEntity", error)
        }
        
        updateFetchedRegions()
    }
    
    private func shouldFetch(rect: MKMapRect, areaLevel: AreaLevel) -> [FetchedMapRect]? {
        // TODO: Add check for savedAt
        var itemsToDelete: [FetchedMapRect] = []
        let now = Date()
        let fetchedRegions = (fetchedAreas[areaLevel] ?? []).filter { fetchedRegion in
            if let savedAt = fetchedRegion.entity.savedAt, now.timeIntervalSince(savedAt) > Self.cachedRegionExpirySeconds {
                itemsToDelete.append(fetchedRegion)
                return false
            }
            return true
        }
        
        if !itemsToDelete.isEmpty {
            itemsToDelete.forEach { dataStack.viewContext.delete($0.entity) }
            
            do {
                try dataStack.saveContext()
            } catch {
                print("Error deleting expired areas")
            }
        }
        
        var intersectingRects: [FetchedMapRect] = []
        
        let totalIntersectionArea = fetchedRegions.reduce(0) { result, fetchedRegion in
            let intersection = rect.intersection(fetchedRegion.rect)
            let intersectionValue = intersection.width * intersection.height
            if intersectionValue > 0 {
                intersectingRects.append(fetchedRegion)
            }
            return result + intersectionValue
        }
        
        if totalIntersectionArea > rect.width * rect.height * Self.intersectionThreshold {
            return nil
        }
        
        return intersectingRects
    }
    
    private func getMapRect(rect: MKMapRect, areaLevel: AreaLevel) -> MKMapRect {
        let x = floor(rect.minX / areaLevel.areaUnit) * areaLevel.areaUnit
        let y = floor(rect.minY / areaLevel.areaUnit) * areaLevel.areaUnit
        let maxX = ceil(rect.maxX / areaLevel.areaUnit) * areaLevel.areaUnit
        let maxY = ceil(rect.maxY / areaLevel.areaUnit) * areaLevel.areaUnit

        return MKMapRect(
            x: x,
            y: y,
            width: maxX - x,
            height: maxY - y
        )
    }
    
    private func devideRect(rect: MKMapRect, areaLevel: AreaLevel) -> [MKMapRect] {
        let xCount = Int(rect.width / areaLevel.areaUnit)
        let yCount = Int(rect.height / areaLevel.areaUnit)

        var rects: [MKMapRect] = []

        for x in 0..<xCount {
            for y in 0..<yCount {
                let newRect = MKMapRect(
                    x: rect.minX + Double(x) * areaLevel.areaUnit,
                    y: rect.minY + Double(y) * areaLevel.areaUnit,
                    width: areaLevel.areaUnit,
                    height: areaLevel.areaUnit
                )
                rects.append(newRect)
            }
        }

        return rects
    }
    
    private func saveActivites(_ activities: [MapActivity]) {
        guard !activities.isEmpty else { return }
        
        let context = dataStack.viewContext
        
        do {
            let existingActivities = try fetchExistingEntities(MapActivityEntity.self, ids: Set(activities.map { $0.id }), context: context)
            let existingActivityIDs = Set(existingActivities.map { $0.id })
            let activitiesToAdd = activities.filter { !existingActivityIDs.contains($0.id) }
            
            // Exit if there is nothing to add
            guard !activitiesToAdd.isEmpty else { return }
            
            let existingUsers = try fetchExistingEntities(UserEntity.self, ids: Set(activities.map { $0.user.id }), context: dataStack.viewContext)
            let existingPlaces = try fetchExistingEntities(PlaceEntity.self, ids: Set(activities.map { $0.place.id }), context: dataStack.viewContext)
            
            var users: [String: UserEntity] = [:]
            existingUsers.forEach { users[$0.id ?? ""] = $0 }
            
            var places: [String: PlaceEntity] = [:]
            existingPlaces.forEach { places[$0.id ?? ""] = $0 }
            
            for activity in activitiesToAdd {
                let user: UserEntity
                let place: PlaceEntity

                if let existingUser = users[activity.user.id] {
                    user = existingUser
                } else {
                    user = activity.user.createUserEntity(context: dataStack.viewContext)
                    users[activity.user.id] = user
                }
                if let existingPlace = places[activity.place.id] {
                    place = existingPlace
                } else {
                    place = activity.place.createPlaceEntity(context: dataStack.viewContext)
                    places[activity.place.id] = place
                }
                
                activity.createMapActivityEntity(context: dataStack.viewContext, user: user, place: place)
                
                originalItems.append(activity)
            }
            
            do {
                try dataStack.saveContext()
            } catch {
                print("Error saving new MapActivityEntity", error)
            }
        } catch {
            print("Error getting existing MapActivityEntity", error)
        }
    }
        
    /// Fetches existing entities by IDs.
    private func fetchExistingEntities<T: NSManagedObject>(_ entityType: T.Type, ids: Set<String>, context: NSManagedObjectContext) throws -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return try context.fetch(request)
    }
    
    private func updateFetchedRegions() {
        let request = NSFetchRequest<RequestedRegionEntity>(entityName: "RequestedRegionEntity")
        
        guard let data = try? dataStack.viewContext.fetch(request) else { return }
        
        var result: [AreaLevel:[FetchedMapRect]] = [
            .A: [],
            .B: [],
            .C: [],
        ]
        
        for region in data {
            guard let width = Double(exactly: region.width), let height = Double(exactly: region.height) else {
                continue
            }
            let level = AreaLevel.categorizeArea(width * height)
            result[level]?.append(.init(entity: region, rect: MKMapRect(x: region.x, y: region.y, width: width, height: height)))
        }
        
        self.fetchedAreas = result
    }
    
    private func getSavedData(startDate: Date) {
        let mapActivitiesRequest: NSFetchRequest<MapActivityEntity> = MapActivityEntity.fetchRequest()
        do {
            let mapActivities = try dataStack.viewContext.fetch(mapActivitiesRequest)
            let activities = mapActivities.filter({ entity in
                if let createdAt = entity.createdAt {
                    return createdAt >= startDate
                }
                return false
            }).compactMap { try? MapActivity($0) }
            originalItems = activities
            if let latestMapContext {
                self.onMapCameraChangeHandler(latestMapContext)
            }
        } catch {
            print(error)
        }
    }
    
    private func removeRequestedRegions() {
        let fetchedRegionsRequest: NSFetchRequest<RequestedRegionEntity> = RequestedRegionEntity.fetchRequest()
        
        do {
            let fetchedRegions = try dataStack.viewContext.fetch(fetchedRegionsRequest)
            
            fetchedRegions.forEach { dataStack.viewContext.delete($0) }
            
            try dataStack.saveContext()
            
            updateFetchedRegions()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Enums
    
    enum LoadingSection: Hashable {
        case fetchEvents
        case fetchActivities
        case inviteLink
    }
    
    enum Throttles: Hashable {
        case fetch
        case display
    }
    
    enum DateOption: String, CaseIterable {
        case day = "Last Day"
        case week = "Last Week"
        case month = "Last Month"
        case year = "Last Year"

        var getDate: Date {
            switch self {
            case .day:
                return Date().addingTimeInterval(-60 * 60 * 24)
            case .week:
                return Date().addingTimeInterval(-60 * 60 * 24 * 7)
            case .month:
                return Date().addingTimeInterval(-60 * 60 * 24 * 30)
            case .year:
                return Date().addingTimeInterval(-60 * 60 * 24 * 365)
            }
        }
    }
}

@available(iOS 17.0, *)
extension ExploreVM17 {
    @MainActor
    func getEvents() async {
        guard !self.loadingSections.contains(.fetchEvents) else { return }
        
        self.loadingSections.insert(.fetchEvents)
        do {
            let data = try await eventsDM.getEvents()
            self.events = data
        } catch {
            print(error)
        }
        self.loadingSections.remove(.fetchEvents)
    }
}


@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use ExploreVM17 for iOS 17 and above")
@MainActor
final class ExploreVM16: ObservableObject {
    
    // MARK: - Shared
    
    @Published var selectedPlaceData: PlaceDetail? = nil
    
    private let placeDM = PlaceDM()
    private let searchDM = SearchDM()
    private let eventsDM = EventsDM()
    
    enum LoadingSection: Hashable {
        case fetchPlace
        case geoActivities
        case fetchEvents
    }
    
    @Published var events: [Event]? = nil
    
    @Published private(set) var loadingSections = Set<LoadingSection>()
    @Published var error: String? = nil
    @Published var searchResults: [MKMapItem]? = nil
    @Published var isSearching: Bool = false
        
    // MARK: - Exclusive
    
    private var locationManager = LocationManager.shared
    
    @Published var selectedPlace: MKMapItem? = nil
    @Published var centerCoordinate = CLLocationCoordinate2D()
    
    init() {
        if let location = locationManager.location {
            self.centerCoordinate = location.coordinate
        }
        
        Task {
            await getEvents()
        }
    }
    
    // MARK: - Shared Methods
    
    func fetchPlace(mapItem: MKMapItem) async {
        self.selectedPlaceData = nil
        self.loadingSections.insert(.fetchPlace)
        do {
            let data = try await placeDM.fetch(mapItem: mapItem)
            self.selectedPlaceData = data
        } catch(let err) {
            self.error = err.localizedDescription
        }
        self.loadingSections.remove(.fetchPlace)
    }
    
    func mapClickHandler(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        do {
            let mapItems = try await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: coordinate, latitudinalMeters: 50, longitudinalMeters: 50))
            
            if let first = mapItems.first {
                return first
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Exlusive Methods
    
    func panToRegion(_ region: MKCoordinateRegion) {
        self.centerCoordinate = region.center
    }
}

extension ExploreVM16 {
    func getEvents() async {
        guard !self.loadingSections.contains(.fetchEvents) else { return }
        
        self.loadingSections.insert(.fetchEvents)
        do {
            let data = try await eventsDM.getEvents()
            self.events = data
        } catch {
            print(error)
        }
        self.loadingSections.remove(.fetchEvents)
    }
}
