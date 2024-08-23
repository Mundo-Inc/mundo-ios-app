//
//  PlaceVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import Foundation

final class PlaceVM: ObservableObject, LoadingSections {
    private let placeDM = PlaceDM()
    
    @Published private(set) var place: PlaceDetail?
    @Published private(set) var mediaItems: [MediaItem]? = nil
    @Published var expandedMediaScrollPosition: String? = nil
    
    enum ScoresTab {
        case googlePhantomYelp
        case scores
        case map
    }
    
    @Published var scoresTabView: ScoresTab = .googlePhantomYelp
    
    @Published var presentedSheet: Sheets? = nil
    @Published var activeTab: PlaceTab = .media
    @Published var expandedMedia: MediaItem? = nil
    
    /// user's lists that include this place
    @Published var includedLists: [String]? = nil
    
    @Published var loadingSections = Set<LoadingSection>()
    
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
    
    private var mediaPagination: Pagination? = nil
    
    // MARK: - Public Methods
    
    func fetchMedia(_ type: RefreshNewAction) async {
        guard let place = place, !loadingSections.contains(.fetchingMedia) else { return }
        
        if type == .refresh {
            mediaPagination = nil
        } else if let mediaPagination, !mediaPagination.hasMore {
            return
        }
        
        setLoadingState(.fetchingMedia, to: true)
        
        defer {
            setLoadingState(.fetchingMedia, to: false)
        }
        
        do {
            let page = (mediaPagination?.page ?? 0) + 1
            
            let data = try await placeDM.getMedias(id: place.id, page: page)
            
            await MainActor.run {
                if page == 1 {
                    if let photos = place.thirdParty.yelp?.photos, !photos.isEmpty {
                        mediaItems = photos
                    }
                    if mediaItems != nil {
                        mediaItems!.append(contentsOf: data.data)
                    } else {
                        mediaItems = data.data
                    }
                } else if mediaItems != nil {
                    mediaItems!.append(contentsOf: data.data)
                } else {
                    mediaItems = data.data
                }
            }
            
            self.mediaPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
    }
    
    func loadMoreMedia(currentItem: MediaItem) async {
        guard let mediaItems, !loadingSections.contains(.fetchingMedia) else { return }
        let thresholdIndex = mediaItems.index(mediaItems.endIndex, offsetBy: -5)
        if mediaItems.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await fetchMedia(.new)
        }
    }
    
    func updateIncludedLists(id: String? = nil) async {
        guard let id = id ?? self.place?.id, !loadingSections.contains(.fetchingList) else { return }
        
        setLoadingState(.fetchingList, to: true)
        
        defer {
            setLoadingState(.fetchingList, to: false)
        }
        
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
    
    enum LoadingSection: Hashable {
        case fetchingMedia
        case fetchingList
    }
}

enum PlaceTab: String, CaseIterable, Hashable {
    case reviews = "Reviews"
    case media = "Media"
}
