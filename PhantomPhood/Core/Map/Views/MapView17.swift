//
//  MapView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/13/23.
//

import SwiftUI
import MapKit
import Kingfisher

@available(iOS 17.0, *)
struct MapView17: View {
    @ObservedObject var appData = AppData.shared
    @ObservedObject var mapVM: MapViewModel
    @State var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var selection: MapFeature? = nil
    
    @State var selectedMapItem: MKMapItem? = nil
    
    @State var throttle = Throttle(interval: 2)
    
    @State var selectedMapActivity: MapActivity? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selection) {
                ForEach(mapVM.mapClusterActiviteis.clustered) { clusteredActivities in
                    Annotation("Activities", coordinate: clusteredActivities.coordinate) {
                        HStack(spacing: 4) {
                            Image(.activity)
                                .foregroundStyle(Color.accentColor)
                            
                            Text("\(clusteredActivities.count)")
                                .foregroundStyle(.primary)
                        }
                        .font(.custom(style: .body))
                        .fontWeight(.medium)
                        .padding(.all, 5)
                        .padding(.trailing, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .foregroundStyle(Color.themeBG)
                        }
                    }
                    .annotationTitles(.hidden)
                }
                
                ForEach(mapVM.mapClusterActiviteis.solo) { activity in
                    Annotation("Activity", coordinate: activity.locationCoordinate) {
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
                            selectedMapActivity = activity
                        }
                    }
                    .annotationTitles(.hidden)
                }
                
                if let searchResults = mapVM.searchResults, !searchResults.isEmpty {
                    ForEach(searchResults, id: \.self) { item in
                        Annotation(item.name ?? "Unknown", coordinate: item.placemark.coordinate) {
                            Group {
                                if let category = item.pointOfInterestCategory {
                                    category.image
                                } else {
                                    Image(systemName: "mappin.and.ellipse.circle.fill")
                                }
                            }
                            .frame(width: 36, height: 36)
                            .background(Color.themePrimary.opacity(0.3))
                            .clipShape(Circle())
                            .onTapGesture {
                                Task {
                                    if let category = item.pointOfInterestCategory {
                                        if !AcceptablePointOfInterestCategories.contains(category) {
                                            withAnimation {
                                                self.selectedMapItem = nil
                                            }
                                            return
                                        }
                                    }
                                    withAnimation {
                                        self.selectedMapItem = item
                                    }
                                    await mapVM.fetchPlace(mapItem: item)
                                }
                            }
                        }
                    }
                }
                
                UserAnnotation()
            }
            .sheet(isPresented: Binding(optionalValue: $selectedMapActivity), content: {
                MapActivityView(mapActivity: $selectedMapActivity)
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
                MapUserLocationButton()
            }
            .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
                mapVM.updateClusters(region: mapCameraUpdateContext.region)
                guard !mapVM.isActiviteisLoading else { return }
                throttle.call {
                    Task {
                        await mapVM.updateGeoActivities(for: mapCameraUpdateContext.region)
                    }
                }
            })
            .zIndex(1)
            
            
            if let item = self.selectedMapItem {
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
                                self.selectedMapItem = nil
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .padding()
                        }
                    }
                    .padding(.leading, 8)
                    
                    VStack {
                        if let place = mapVM.selectedPlaceData {
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
                    .onTapGesture {
                        if let place = mapVM.selectedPlaceData {
                            appData.mapNavStack.append(.place(id: place.id))
                        } else {
                            if let title = item.placemark.title {
                                appData.mapNavStack.append(.placeMapPlace(mapPlace: MapPlace(coordinate: item.placemark.coordinate, title: title)))
                            }
                        }
                    }
                }
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 15))
                .frame(maxHeight: 240)
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.bouncy, value: selectedMapItem)
                .zIndex(2)
            }
        }
        .onChange(of: selection) { newValue in
            if let item = newValue {
                withAnimation {
                    self.position = .region(.init(center: item.coordinate, latitudinalMeters: 500, longitudinalMeters: 500))
                }
                
                Task {
                    await mapVM.fetchPlace(mapFeature: item)
                }
                
                let mapItemRequest = MKMapItemRequest(feature: item)
                mapItemRequest.getMapItem { mapItem, error in
                    if let mapItem {
                        self.selectedMapItem = mapItem
                    } else {
                        self.selectedMapItem = nil
                    }
                }
            } else {
                withAnimation {
                    self.selectedMapItem = nil
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    MapView17(mapVM: MapViewModel())
}
