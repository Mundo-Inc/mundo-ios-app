//
//  ExploreView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/17/24.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct ExploreView17: View {
    @EnvironmentObject private var exploreSearchVM: ExploreSearchVM
    @Environment(\.dismissSearch) private var dismissSearch
    /// for iOS 17
    @StateObject private var vm = ExploreVM17()
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $vm.position) {
                if let searchResults = vm.searchResults {
                    ForEach(vm.activities.filter({ activity in
                        searchResults.contains { result in
                            if let name = result.name, let first = activity.first {
                                if first.place.name == name {
                                    return true
                                }
                            }
                            
                            return false
                        }
                    })) { item in
                        UserActivityMapAnnotation(item: item)
                    }
                } else {
                    ForEach(vm.activities) { item in
                        UserActivityMapAnnotation(item: item)
                    }
                }
                
                ForEach(vm.events) { item in
                    UserActivityMapAnnotation(item: item)
                }
                                
                if let searchResults = vm.searchResults, !searchResults.isEmpty {
                    ForEach(searchResults, id: \.self) { item in
                        Annotation(item.name ?? "Unknown", coordinate: item.placemark.coordinate) {
                            ScalableMapAnnotation(scale: vm.scale, image: item.pointOfInterestCategory?.image)
                                .onTapGesture {
                                    if let name = item.name {
                                        AppData.shared.goTo(.placeMapPlace(mapPlace: .init(coordinate: item.placemark.coordinate, title: name), action: nil))
                                    }
                                }
                        }
                    }
                }
                
                UserAnnotation()
            }
            .mapStyle(.standard(emphasis: .automatic, pointsOfInterest: .excludingAll))
            .mapControlVisibility(.hidden)
            .onMapCameraChange(frequency: .continuous, vm.onMapCameraChangeContinuosHandler)
            .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
                exploreSearchVM.mapRegion = mapCameraUpdateContext.region
            })
            .ignoresSafeArea()
            .environmentObject(vm)
            
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .trailing) {
                    if let first = vm.events.sorted(by: { a, b in
                        if let eventA = a.event, let eventB = b.event, let center = vm.latestMapContext?.region.center {
                            return eventA.place.coordinates.distance(to: center) < eventB.place.coordinates.distance(to: center)
                        }
                        
                        return false
                    }).first {
                        Button {
                            if let event = first.event {
                                AppData.shared.goTo(.event(.data(event)))
                            }
                        } label: {
                            if let event = first.event {
                                ImageLoader(event.logo)
                                    .frame(width: 50, height: 50)
                                    .clipShape(.rect(cornerRadius: 10))
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            vm.isInviteBannerPresented = true
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.accentColor.gradient)
                            .overlay {
                                HStack {
                                    if vm.activities.isEmpty {
                                        Text("Invite friends")
                                            .padding(.leading, 8)
                                            .cfont(.subheadline)
                                            .frame(maxWidth: .infinity)
                                    }
                                    
                                    Image(systemName: "person.fill.badge.plus")
                                        .font(.system(size: 20))
                                        .frame(width: 50)
                                }
                                .foregroundStyle(Color.white)
                            }
                            .frame(width: vm.activities.isEmpty ? 160 : 50, height: 50)
                            .animation(.spring, value: vm.activities.isEmpty)
                    }
                    
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
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.themePrimary)
                            .overlay {
                                Image(systemName: vm.position.followsUserHeading ? "location.north.line.fill" : vm.position.followsUserLocation ? "location.fill" : "location")
                                    .font(.system(size: 20))
                                    .foregroundStyle(vm.position.followsUserHeading || vm.position.followsUserLocation ? Color.accentColor : Color.white)
                            }
                    }
                }
                .padding(.trailing, 8)
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
            if vm.isInviteBannerPresented {
                InviteFriendsBanner {
                    withAnimation {
                        vm.isInviteBannerPresented = false
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
            }
            
            VStack(alignment: .leading) {
                Menu {
                    Picker("Activities Scope", selection: $vm.activitiesScope) {
                        ForEach(MapDM.Scope.allCases, id: \.self) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                } label: {
                    Label {
                        Text(vm.activitiesScope.title)
                    } icon: {
                        Image(systemName: "eye")
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 25).foregroundStyle(Color.accentColor))
                }
                .foregroundStyle(Color.black)
                
                Menu {
                    Picker("Start Date", selection: $vm.startDate) {
                        ForEach(ExploreVM17.DateOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                } label: {
                    Label {
                        Text(vm.startDate.rawValue)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 25).foregroundStyle(Color.black))
                }
                .foregroundStyle(Color.white)
            }
            .padding(.horizontal)
            .padding(.top, 70)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ExploreSearchView(exploreSearchVM: exploreSearchVM, isSearching: $vm.isSearching, searchResults: $vm.searchResults) { region in
                vm.panToRegion(region)
            }
        }
        .sheet(item: $vm.presentedSheet) { presentedSheet in
            switch presentedSheet {
            case .activityCluster(let clusteredMapActivity):
                MapActivitySheet(clusteredMapActivity)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ExploreView17()
        .environmentObject(ExploreSearchVM())
}
