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
import Combine

@available(iOS 17.0, *)
final class ExploreVM17: ObservableObject, LoadingSections {
    static let annotationLimitOnMap: Int = 30
    static let mapAnnotationUpdateThruttle: Double = 1.5
    
    private static let intersectionThreshold: Double = 0.5
    private static let cachedRegionExpirySeconds: Double = 90
    
    // MARK: - Shared
    
    private let dataStack = DataStack.shared
    private let eventsDM = EventsDM()
    private let mapDM = MapDM()
    
    @Published var events: [ClusteredMapActivity] = []
    private var originalEvents: [Event]? = nil
    
    @Published var showSet = Set<String>()
    @Published var activities: [ClusteredMapActivity] = []
    
    @Published var isInviteBannerPresented: Bool = true
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var searchResults: [MKMapItem]? = nil
    @Published var isSearching: Bool = false
    @Published var startDate: DateOption = .year
    @Published var activitiesScope: MapDM.Scope = .global
    
    private var throttles = Set<Throttles>()
    
    // MARK: - Exclusive
    
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published private(set) var scale: CGFloat = 1
    @Published var presentedSheet: Sheets? = nil
    
    private(set) var originalItems: [MapActivity] = []
    private(set) var fetchedAreas: [AreaLevel: [FetchedMapRect]] = [
        .A: [],
        .B: [],
        .C: [],
    ]
    
    var latestMapContext: MapCameraUpdateContext?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        updateFetchedRegions()
        
        $startDate
            .sink { [weak self] value in
                self?.getSavedData(startDate: value.getDate)
                self?.removeRequestedRegions()
            }
            .store(in: &cancellables)
        
        $activitiesScope
            .sink { [weak self] value in
                guard let self else { return }
                
                if value == .followings {
                    try? self.dataStack.removeMapActivities()
                }
                
                self.removeRequestedRegions()
                
                self.getSavedData(startDate: self.startDate.getDate)
                if let context = self.latestMapContext {
                    self.onMapCameraChangeContinuosHandler(context)
                }
            }
            .store(in: &cancellables)
        
        Task {
            await getEvents()
        }
    }
    
    private var mapActivityCancellable: AnyCancellable? = nil
    private func setCDPublisher(startDate: Date) {
        if let cancellable = mapActivityCancellable {
            cancellable.cancel()
            mapActivityCancellable = nil
        }
        
        let request = MapActivityEntity.fetchRequest()
        request.predicate = .init(format: "createdAt > %@", startDate as CVarArg)
        request.sortDescriptors = [
            .init(keyPath: \MapActivityEntity.createdAt, ascending: false)
        ]
        
        self.mapActivityCancellable = CDPublisher(request: request, context: dataStack.viewContext)
            .map({ $0.compactMap { entity in
                try? MapActivity(entity)
            } })
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error receiving completion: \(error)")
                }
            }, receiveValue: { mapActivity in
                self.originalItems = mapActivity
            })
    }
    
    // MARK: - Shared Methods
    
    func panToRegion(_ region: MKCoordinateRegion) {
        DispatchQueue.main.async {
            withAnimation {
                self.position = .region(region)
            }
        }
    }
    
    // MARK: - Exclusive Methods
    
    func fetchData(rect: MKMapRect) async {
        let areaLevel = AreaLevel.categorizeArea(rect.width * rect.height)
        let fetchRect = getMapRect(rect: rect, areaLevel: areaLevel)
        
        guard let intersectingRects = shouldFetch(rect: fetchRect, areaLevel: areaLevel) else { return }
        
        setLoadingState(.fetchActivities, to: true)
        
        defer {
            setLoadingState(.fetchActivities, to: false)
        }
        
        do {
            let ne = MKMapPoint(x: fetchRect.maxX, y: fetchRect.minY)
            let sw = MKMapPoint(x: fetchRect.minX, y: fetchRect.maxY)
            
            let data = try await mapDM.getMapActivities(ne: ne.coordinate, sw: sw.coordinate, startDate: startDate.getDate, scope: self.activitiesScope)
            
            saveActivites(data)
            addFetchedRect(fetchRect, areaLevel: areaLevel, intersectingRects: intersectingRects)
        } catch {
            presentErrorToast(error, silent: true)
        }
    }
    
    func onMapCameraChangeContinuosHandler(_ context: MapCameraUpdateContext) {
        DispatchQueue.main.async {
            if self.isInviteBannerPresented && self.position.positionedByUser {
                withAnimation {
                    self.isInviteBannerPresented = false
                }
            }
            
            self.latestMapContext = context
            
            self.scale = context.scaleValue
        }
        
        if !throttles.contains(.fetch) && !loadingSections.contains(.fetchActivities) {
            throttles.insert(.fetch)
            
            Task {
                await self.fetchData(rect: context.rect)
                updateAnnotations()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.throttles.remove(.fetch)
            }
        }
        
        guard !throttles.contains(.display) else { return }
        
        throttles.insert(.display)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.mapAnnotationUpdateThruttle) {
            self.throttles.remove(.display)
            self.updateAnnotations()
        }
    }
    
    private func updateAnnotations() {
        guard let context = self.latestMapContext else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var (acttivities, events) = self.makeCluster(self.originalItems.filter({ context.rect.contains(.init($0.place.coordinates)) }), events: self.originalEvents?.filter({ context.rect.contains(.init($0.place
                .coordinates)) }))
            
            if acttivities.count > Self.annotationLimitOnMap {
                acttivities = Array(acttivities.prefix(Self.annotationLimitOnMap))
            }
            
            DispatchQueue.main.async {
                self.events = events
                self.activities = acttivities
            }
        }
    }
    
    
    private func makeCluster(_ items: [MapActivity], events: [Event]?) -> ([ClusteredMapActivity], [ClusteredMapActivity]) {
        /// placeId, activity
        var dict: [String: [MapActivity]] = [:]
        
        for item in items {
            if dict[item.place.id] == nil {
                dict[item.place.id] = [item]
            } else {
                dict[item.place.id]!.append(item)
            }
        }
        
        if let events {
            var clusteredEvents: [ClusteredMapActivity] = []
            
            for event in events {
                if dict[event.place.id] != nil {
                    clusteredEvents.append(.init(items: dict[event.place.id]!, event: event))
                    dict.removeValue(forKey: event.place.id)
                } else {
                    clusteredEvents.append(.init(items: [], event: event))
                }
            }
            
            return (dict.values.map { ClusteredMapActivity(items: $0) }, clusteredEvents)
        } else {
            return (dict.values.map { ClusteredMapActivity(items: $0) }, [])
        }
    }
    
    // MARK: - Private Methods
    
    private func addFetchedRect(_ rect: MKMapRect, areaLevel: AreaLevel, intersectingRects: [FetchedMapRect]) {
        let unitRects = divideRect(rect: rect, areaLevel: areaLevel).filter { r in
            !intersectingRects.contains { fetchedMapRegion in
                fetchedMapRegion.rect.midX == r.midX && fetchedMapRegion.rect.midY == r.midY
            }
        }
        
        dataStack.viewContext.performAndWait {
            for item in unitRects {
                let entity = RequestedRegionEntity(context: dataStack.viewContext)
                entity.x = item.origin.x
                entity.y = item.origin.y
                entity.width = item.width
                entity.height = item.height
                entity.savedAt = .now
                
                try? dataStack.viewContext.obtainPermanentIDs(for: [entity])
            }
            
            do {
                if dataStack.viewContext.hasChanges {
                    try dataStack.viewContext.save()
                }
            } catch {
                presentErrorToast(error, debug: "Error saving new RequestedRegionEntity", silent: true)
            }
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
            dataStack.viewContext.performAndWait {
                itemsToDelete.forEach { self.dataStack.viewContext.delete($0.entity) }
                do {
                    if dataStack.viewContext.hasChanges {
                        try dataStack.viewContext.save()
                    }
                } catch {
                    presentErrorToast(error, debug: "Error deleting expired areas", silent: true)
                }
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
    
    private func divideRect(rect: MKMapRect, areaLevel: AreaLevel) -> [MKMapRect] {
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
        
        context.performAndWait {
            do {
                // Fetch existing entities
                let existingActivities = try fetchExistingEntities(MapActivityEntity.self, ids: Set(activities.compactMap { $0.id }), context: context)
                let existingActivityIDs = Set(existingActivities.compactMap { $0.id })
                let activitiesToAdd = activities.filter { !existingActivityIDs.contains($0.id) }
                
                // Exit if there is nothing to add
                guard !activitiesToAdd.isEmpty else { return }
                
                let existingUsers = try fetchExistingEntities(UserEntity.self, ids: Set(activities.compactMap { $0.user.id }), context: context)
                let existingPlaces = try fetchExistingEntities(PlaceEntity.self, ids: Set(activities.compactMap { $0.place.id }), context: context)
                
                var usersDict = Dictionary(uniqueKeysWithValues: existingUsers.compactMap { ($0.id, $0) })
                var placesDict = Dictionary(uniqueKeysWithValues: existingPlaces.compactMap { ($0.id, $0) })
                
                for activity in activitiesToAdd {
                    let user = usersDict[activity.user.id] ?? {
                        let newUser = activity.user.createOrModifyUserEntity(context: context)
                        usersDict[activity.user.id] = newUser
                        return newUser
                    }()
                    
                    let place = placesDict[activity.place.id] ?? {
                        let newPlace = activity.place.createPlaceEntity(context: context)
                        placesDict[activity.place.id] = newPlace
                        return newPlace
                    }()
                    
                    activity.createMapActivityEntity(context: context, user: user, place: place)
                }
                
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                presentErrorToast(error, debug: "Error getting existing MapActivityEntity", silent: true)
            }
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
        setCDPublisher(startDate: startDate)
        // TODO: Update the map?
    }
    
    private func removeRequestedRegions() {
        try? dataStack.removeRequestedRegions()
        
        updateFetchedRegions()
    }
    
    // MARK: - Enums
    
    enum LoadingSection: Hashable {
        case fetchEvents
        case fetchActivities
    }
    
    enum Throttles: Hashable {
        case fetch
        case display
    }
    
    enum Sheets: Identifiable, Hashable {
        var id: Int {
            switch self {
            case .activityCluster(let clusteredMapActivity):
                return clusteredMapActivity.hashValue
            }
        }
        
        case activityCluster(ClusteredMapActivity)
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
    func getEvents() async {
        guard !self.loadingSections.contains(.fetchEvents) else { return }
        
        setLoadingState(.fetchEvents, to: true)
        
        defer {
            setLoadingState(.fetchEvents, to: false)
        }
        
        do {
            let data = try await eventsDM.getEvents()
            
            await MainActor.run {
                self.originalEvents = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
}


@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use ExploreVM17 for iOS 17 and above")
final class ExploreVM16: ObservableObject, LoadingSections {
    
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
    
    private var originalEvents: [Event]? = nil
    
    @Published var loadingSections = Set<LoadingSection>()
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
        await MainActor.run {
            self.selectedPlaceData = nil
        }
        
        setLoadingState(.fetchPlace, to: true)
        
        defer {
            setLoadingState(.fetchPlace, to: false)
        }
        
        do {
            let data = try await placeDM.fetch(mapItem: mapItem)
            
            await MainActor.run {
                self.selectedPlaceData = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func mapClickHandler(coordinate: CLLocationCoordinate2D) async -> MKMapItem? {
        do {
            let mapItems = try await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: coordinate, latitudinalMeters: 50, longitudinalMeters: 50))
            
            return mapItems.first
        } catch {
            return nil
        }
    }
    
    // MARK: - Exlusive Methods
    
    func panToRegion(_ region: MKCoordinateRegion) {
        DispatchQueue.main.async {
            withAnimation {
                self.centerCoordinate = region.center
            }
        }
    }
}

extension ExploreVM16 {
    func getEvents() async {
        guard !self.loadingSections.contains(.fetchEvents) else { return }
        
        setLoadingState(.fetchEvents, to: true)
        
        defer {
            setLoadingState(.fetchEvents, to: false)
        }
        
        do {
            let data = try await eventsDM.getEvents()
            
            await MainActor.run {
                self.originalEvents = data
            }
        } catch {
            presentErrorToast(error)
        }
    }
}
