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
    private var appData = AppData.shared
    
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
                            if let name = result.name {
                                if activity.place.name == name {
                                    return true
                                }
                            }
                            
                            return false
                        }
                    })) { item in
                        Annotation(item.place.name, coordinate: item.place.coordinates) {
                            ZStack {
                                if vm.showSet.contains(item.id) {
                                    ProfileImage(item.user.profileImage, size: 50, cornerRadius: 5, borderColor: item.user.color)
                                        .transition(AnyTransition.asymmetric(insertion: .scale(scale: 0).animation(.bouncy(duration: 0.5)), removal: .identity.animation(.easeIn(duration: 0))))
                                } else {
                                    Color.clear
                                }
                            }
                            .frame(width: 50, height: 50)
                            .onTapGesture {
                                vm.panToRegion(.init(center: item.place.coordinates, latitudinalMeters: 20000, longitudinalMeters: 20000))
                            }
                            .scaleEffect(vm.scale)
                            .onAppear {
                                vm.showSet.insert(item.id)
                            }
                            .onDisappear {
                                vm.showSet.remove(item.id)
                            }
                        }
                        .annotationTitles(vm.scale > 0.8 ? .automatic : .hidden)
                    }
                } else {
                    ForEach(vm.activities) { item in
                        Annotation(item.place.name, coordinate: item.place.coordinates) {
                            ZStack {
                                if vm.showSet.contains(item.id) {
                                    ProfileImage(item.user.profileImage, size: 50, cornerRadius: 5, borderColor: item.user.color)
                                        .transition(AnyTransition.asymmetric(insertion: .scale(scale: 0).animation(.bouncy(duration: 0.5)), removal: .identity.animation(.easeIn(duration: 0))))
                                } else {
                                    Color.clear
                                }
                            }
                            .frame(width: 50, height: 50)
                            .onTapGesture {
                                vm.panToRegion(.init(center: item.place.coordinates, latitudinalMeters: 20000, longitudinalMeters: 20000))
                            }
                            .scaleEffect(vm.scale)
                            .onAppear {
                                vm.showSet.insert(item.id)
                            }
                            .onDisappear {
                                vm.showSet.remove(item.id)
                            }
                        }
                        .annotationTitles(vm.scale > 0.8 ? .automatic : .hidden)
                    }
                }
                
                if let events = vm.events {
                    ForEach(events) { event in
                        Annotation(event.name, coordinate: event.coordinate) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(Color.black)
                                
                                if let logo = event.logo {
                                    KFImage.url(logo)
                                        .placeholder {
                                            Image(systemName: "arrow.down.circle.dotted")
                                                .foregroundStyle(Color.white.opacity(0.5))
                                        }
                                        .loadDiskFileSynchronously()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .contentShape(RoundedRectangle(cornerRadius: 5))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .frame(width: 36, height: 36)
                                } else {
                                    Image(systemName: "laser.burst")
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                            }
                            .onTapGesture {
                                appData.goTo(AppRoute.event(IdOrData.data(event)))
                            }
                        }
                    }
                }
                
                if let searchResults = vm.searchResults, !searchResults.isEmpty {
                    ForEach(searchResults, id: \.self) { item in
                        Annotation(item.name ?? "Unknown", coordinate: item.placemark.coordinate) {
                            CustomMapMarker(image: item.pointOfInterestCategory?.image)
                                .scaleEffect(vm.scale)
                                .onTapGesture {
                                    if let name = item.name {
                                        appData.goTo(.placeMapPlace(mapPlace: .init(coordinate: item.placemark.coordinate, title: name), action: nil))
                                    }
                                }
                        }
                    }
                }
                
                UserAnnotation()
            }
            .ignoresSafeArea()
            .mapStyle(.standard(emphasis: .automatic, pointsOfInterest: .excludingAll))
            .mapControlVisibility(.hidden)
            .onMapCameraChange(frequency: .continuous, vm.onMapCameraChangeHandler)
            .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
                exploreSearchVM.mapRegion = mapCameraUpdateContext.region
            })
            
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .trailing) {
                    Button {
                        vm.getInviteLink()
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.accentColor.gradient)
                            .overlay {
                                HStack {
                                    if vm.activities.isEmpty {
                                        Text("Invite friends")
                                            .padding(.leading, 8)
                                            .font(.custom(style: .subheadline))
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
            .padding(.bottom, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
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
                .disabled(true)
                
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
    }
}

@available(iOS 17.0, *)
#Preview {
    ExploreView17()
        .environmentObject(ExploreSearchVM())
}
