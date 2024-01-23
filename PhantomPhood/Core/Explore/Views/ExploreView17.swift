//
//  ExploreView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import SwiftUI
import MapKit
import Kingfisher

@available(iOS 17.0, *)
struct ExploreView17: View {
    @EnvironmentObject private var exploreSearchVM: ExploreSearchVM
    @Environment(\.dismissSearch) private var dismissSearch
    /// for iOS 17
    @StateObject private var vm = ExploreVM17()
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                Map(position: $vm.position, selection: $vm.selection) {
                    ForEach(vm.mapClusterActivities.clustered) { clusteredActivities in
                        MapCircle(center: clusteredActivities.location.coordinate, radius: clusteredActivities.radius)
                            .foregroundStyle(Color.accentColor.opacity(0.3))
                            .stroke(Color.accentColor.opacity(0.6))
                            .tint(Color.accentColor)
                        
                        //                        MapCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance)
                        
                        //                        Annotation("Activities", coordinate: clusteredActivities.coordinate) {
                        //                            HStack(spacing: 4) {
                        //                                Image(.activity)
                        //                                    .foregroundStyle(Color.accentColor)
                        //
                        //                                Text("\(clusteredActivities.count)")
                        //                                    .foregroundStyle(.primary)
                        //                            }
                        //                            .font(.custom(style: .body))
                        //                            .fontWeight(.medium)
                        //                            .padding(.all, 5)
                        //                            .padding(.trailing, 5)
                        //                            .background {
                        //                                RoundedRectangle(cornerRadius: 14)
                        //                                    .foregroundStyle(Color.themeBG)
                        //                            }
                        //                        }
                        //                        .annotationTitles(.hidden)
                        //                            }
                    }
                    
                    ForEach(vm.mapClusterActivities.solo) { activity in
                        Annotation("Activity", coordinate: activity.location.coordinate) {
                            HStack(spacing: -10) {
                                ForEach(activity.activities.data.indices, id: \.self) { index in
                                    if index < 3 {
                                        ProfileImage(activity.activities.data[index].profileImage, size: 30)
                                            .overlay(alignment: .bottomLeading) {
                                                if activity.activities.data[index].checkinsCount > 1 || activity.activities.data[index].reviewsCount > 1 {
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 15, height: 15)
                                                            .foregroundStyle(Color.black)
                                                        
                                                        Text("\(activity.activities.data[index].checkinsCount + activity.activities.data[index].reviewsCount)")
                                                            .font(.custom(style: .caption2))
                                                            .foregroundStyle(Color.white)
                                                    }
                                                    .frame(width: 15, height: 15)
                                                }
                                            }
                                    }
                                }
                                if activity.activities.data.count > 3 {
                                    Text("+\(max(activity.activities.data.count - 3, 0))")
                                        .padding(.leading, 12)
                                }
                            }
                            .font(.custom(style: .body))
                            .fontWeight(.medium)
                            .padding(.all, 5)
                            .background {
                                RoundedRectangle(cornerRadius: 14)
                                    .foregroundStyle(Color.themeBG)
                            }
                            .onTapGesture {
                                vm.selectedMapActivity = activity
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                    
                    if let searchResults = vm.searchResults, !searchResults.isEmpty {
                        ForEach(searchResults, id: \.self) { item in
                            Annotation(item.name ?? "Unknown", coordinate: item.placemark.coordinate) {
                                CustomMapMarker(image: item.pointOfInterestCategory?.image)
                                    .scaleEffect(vm.scale)
                                    .onTapGesture {
                                        Task {
                                            if let category = item.pointOfInterestCategory {
                                                if !SearchDM.AcceptablePointOfInterestCategories.contains(category) {
                                                    withAnimation {
                                                        vm.selectedMapItem = nil
                                                    }
                                                    return
                                                }
                                            }
                                            withAnimation {
                                                vm.selectedMapItem = item
                                            }
                                            await vm.fetchPlace(mapItem: item)
                                        }
                                    }
                            }
                        }
                    }
                    
                    UserAnnotation()
                }
                .sheet(isPresented: Binding(optionalValue: $vm.selectedMapActivity), content: {
                    MapActivityView(mapActivity: $vm.selectedMapActivity)
                        .presentationBackground(.thinMaterial)
                        .presentationDetents([.height(320), .large])
                })
                .mapFeatureSelectionDisabled({ item in
                    if let pointOfInterestCategory = item.pointOfInterestCategory {
                        switch pointOfInterestCategory {
                        case .cafe:
                            return false
                        case .restaurant:
                            return false
                        case .bakery:
                            return false
                        case .winery:
                            return false
                        case .nightlife:
                            return false
                        default:
                            return true
                        }
                    } else {
                        return false
                    }
                })
                .mapControlVisibility(.visible)
                .mapControls {
                    MapCompass()
                }
                .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
                    exploreSearchVM.mapRegion = mapCameraUpdateContext.region
                    
                    vm.scale = mapCameraUpdateContext.scaleValue
                    
                    guard !vm.isActiviteisLoading else { return }
                    vm.throttle.call {
                        Task {
                            await vm.updateGeoActivities(for: mapCameraUpdateContext.region)
                        }
                    }
                })
                .onMapCameraChange(frequency: .onEnd, { mapCameraUpdateContext in
                    vm.updateClusters(region: mapCameraUpdateContext.region, force: false)
                })
                .zIndex(1)
                
                Button {
                    if vm.position.followsUserLocation && !vm.position.followsUserHeading {
                        withAnimation {
                            vm.position = .userLocation(followsHeading: true, fallback: MapCameraPosition.automatic)
                        }
                    } else if !vm.position.followsUserLocation {
                        withAnimation {
                            vm.position = .userLocation(fallback: MapCameraPosition.automatic)
                        }
                    }
                } label: {
                    Circle()
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundStyle(Color.themePrimary)
                        .overlay {
                            Image(systemName: vm.position.followsUserHeading ? "location.north.line.fill" : vm.position.followsUserLocation ? "location.fill" : "location")
                                .foregroundStyle(vm.position.followsUserHeading || vm.position.followsUserLocation ? Color.accentColor : Color.white)
                        }
                }
                .padding(.trailing, 5)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .zIndex(2)
                
                if let item = vm.selectedMapItem {
                    VStack {
                        HStack {
                            HStack {
                                if let imageCategory = item.pointOfInterestCategory {
                                    imageCategory.image
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.secondary)
                                        .frame(height: 32)
                                }
                                
                                VStack {
                                    Text(item.name ?? "Unknown")
                                        .lineLimit(1)
                                        .font(.custom(style: .headline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top)
                                    
                                    Group {
                                        if let distance = distanceFromMe(lat: item.placemark.coordinate.latitude, lng: item.placemark.coordinate.longitude, unit: .miles) {
                                            Text("\(String(format: "%.1f", distance)) Miles away")
                                        } else {
                                            Text("- Miles away")
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(style: .caption))
                                }
                                
                            }
                            
                            Button {
                                withAnimation {
                                    vm.selectedMapItem = nil
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .padding()
                            }
                        }
                        .padding(.leading, 8)
                        
                        NavigationLink(value: vm.selectedPlaceData != nil ? AppRoute.place(id: vm.selectedPlaceData!.id) : item.placemark.title != nil ? AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: item.placemark.coordinate, title: item.placemark.title!)) : nil) {
                            VStack {
                                if let place = vm.selectedPlaceData {
                                    HStack {
                                        Text("\(place.reviewCount) Reviews")
                                        
                                        if let phantomScore = place.scores.phantom {
                                            Divider()
                                                .frame(maxHeight: 10)
                                            Text("👻 \(String(format: "%.0f", phantomScore))")
                                        }
                                        
                                        if let priceRange = place.priceRange {
                                            Divider()
                                                .frame(maxHeight: 10)
                                            Text(String(repeating: "$", count: priceRange))
                                        }
                                    }
                                    .font(.custom(style: .body))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if !place.media.isEmpty {
                                        ScrollView(.horizontal) {
                                            HStack {
                                                ForEach(place.media) { media in
                                                    if let url = URL(string: media.src) {
                                                        KFImage.url(url)
                                                            .placeholder {
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .frame(width: 90, height: 120)
                                                                    .foregroundStyle(Color.themePrimary.opacity(0.4))
                                                                    .overlay {
                                                                        ProgressView()
                                                                    }
                                                            }
                                                            .loadDiskFileSynchronously()
                                                            .cacheMemoryOnly()
                                                            .fade(duration: 0.25)
                                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .contentShape(RoundedRectangle(cornerRadius: 15))
                                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                                            .frame(width: 90, height: 120)
                                                    }
                                                }
                                            }
                                        }
                                        .scrollIndicators(.hidden)
                                    } else {
                                        if let thumbnail = place.thumbnail, let url = URL(string: thumbnail) {
                                            KFImage.url(url)
                                                .placeholder {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 120)
                                                        .foregroundStyle(Color.themePrimary.opacity(0.4))
                                                        .overlay {
                                                            ProgressView()
                                                        }
                                                }
                                                .loadDiskFileSynchronously()
                                                .cacheMemoryOnly()
                                                .fade(duration: 0.25)
                                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 120)
                                                .contentShape(RoundedRectangle(cornerRadius: 15))
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                        } else {
                                            Text("No images found")
                                        }
                                    }
                                } else {
                                    HStack {
                                        Text("... Reviews")
                                        Divider()
                                            .frame(maxHeight: 10)
                                        Text("Score")
                                        Divider()
                                            .frame(maxHeight: 10)
                                        Text("Price")
                                    }
                                    .font(.custom(style: .body))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .redacted(reason: .placeholder)
                                    
                                    ScrollView(.horizontal) {
                                        HStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 120)
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 120)
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 120)
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 120)
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 120)
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                }
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        .foregroundStyle(.primary)
                    }
                    .background(.thinMaterial)
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(maxHeight: 240)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.bouncy, value: vm.selectedMapItem)
                    .zIndex(3)
                }
            }
            .toolbar {
                if vm.isActiviteisLoading {
                    ToolbarItem(placement: .topBarLeading) {
                        ProgressView()
                    }
                }
            }
            .onChange(of: vm.selection) { newValue in
                if let item = newValue {
                    withAnimation {
                        vm.position = .region(.init(center: item.coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
                    }
                    
                    Task {
                        await vm.fetchPlace(mapFeature: item)
                    }
                    
                    let mapItemRequest = MKMapItemRequest(feature: item)
                    mapItemRequest.getMapItem { mapItem, error in
                        if let mapItem {
                            vm.selectedMapItem = mapItem
                        } else {
                            vm.selectedMapItem = nil
                        }
                    }
                } else {
                    withAnimation {
                        vm.selectedMapItem = nil
                    }
                }
            }
            
            if let searchResults = vm.searchResults, !searchResults.isEmpty {
                Button {
                    withAnimation {
                        vm.searchResults = nil
                    }
                } label: {
                    Label(
                        title: { Text("Clear search results") },
                        icon: { Image(systemName: "xmark") }
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.themePrimary)
                }
                .font(.custom(style: .subheadline))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(y: 6)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        Group {
                            ForEach(MapDefaultSearch.allCases, id: \.self) { item in
                                Button {
                                    Task {
                                        await exploreSearchVM.search(item.search, region: vm.position.region, categories: item.categories)
                                        if !exploreSearchVM.placeSearchResults.isEmpty {
                                            vm.searchResults = exploreSearchVM.placeSearchResults
                                            if let region = getClusterRegion(coordinates: exploreSearchVM.placeSearchResults.map { $0.placemark.coordinate }) {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation {
                                                        vm.panToRegion(region: region)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Label {
                                        Text(item.title)
                                    } icon: {
                                        item.image
                                    }
                                }
                                .disabled(exploreSearchVM.isLoading)
                            }
                        }
                        .controlSize(.mini)
                        .foregroundStyle(Color.accentColor)
                        .buttonStyle(BorderedProminentButtonStyle())
                        .tint(Color.themePrimary)
                        .font(.custom(style: .body))
                    }
                    .padding(.all, 5)
                    .opacity(exploreSearchVM.isLoading ? 0.7 : 1)
                }
                .scrollIndicators(.never)
            }
            
            ExploreSearchView(exploreSearchVM: exploreSearchVM, mapVM: vm)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ExploreView17()
        .environmentObject(ExploreSearchVM())
}
