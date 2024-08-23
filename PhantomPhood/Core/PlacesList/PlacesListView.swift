//
//  PlacesListView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/3/24.
//

import SwiftUI
import MapKit

struct PlacesListView: View {
    @EnvironmentObject private var actionManager: ActionManager
    
    @StateObject private var vm: PlacesListVM
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAnimating = true
    
    init(listId: String) {
        self._vm = StateObject(wrappedValue: PlacesListVM(listId: listId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Circle()
                        .foregroundStyle(.themeBorder)
                        .frame(width: 46, height: 46)
                        .overlay {
                            if let list = vm.list {
                                Emoji(symbol: list.icon, isAnimating: $isAnimating, size: 24)
                            }
                        }
                    
                    VStack {
                        HStack {
                            if let list = vm.list, list.isPrivate {
                                Image(systemName: "lock.fill")
                            }
                            
                            Text(vm.list?.name ?? "List name")
                                .cfont(.headline)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            Image(systemName: "person.2")
                            
                            Text(vm.list?.collaborators.count.description ?? "1")
                                .cfont(.body)
                            
                            Spacer()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Button {
                        withAnimation {
                            vm.tabViewSelection = .list
                        }
                    } label: {
                        Label {
                            Text(PlacesListVM.Tabs.list.title)
                        } icon: {
                            Image(systemName: vm.tabViewSelection == .list ? PlacesListVM.Tabs.list.iconSelected : PlacesListVM.Tabs.list.icon)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .overlay(alignment: .bottom) {
                            if vm.tabViewSelection == .list {
                                Rectangle()
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .foregroundStyle(vm.tabViewSelection == .list ? Color.accentColor : Color.secondary)
                    
                    Divider()
                        .frame(height: 25)
                    
                    Button {
                        withAnimation {
                            vm.tabViewSelection = .map
                        }
                    } label: {
                        Label {
                            Text(PlacesListVM.Tabs.map.title)
                        } icon: {
                            Image(systemName: vm.tabViewSelection == .map ? PlacesListVM.Tabs.map.iconSelected : PlacesListVM.Tabs.map.icon)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .overlay(alignment: .bottom) {
                            if vm.tabViewSelection == .map {
                                Rectangle()
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .foregroundStyle(vm.tabViewSelection == .map ? Color.accentColor : Color.secondary)
                }
                .cfont(.headline)
            }
            .redacted(reason: vm.list == nil ? .placeholder : [])
            
            Divider()
            
            TabView(selection: $vm.tabViewSelection) {
                ScrollView {
                    LazyVStack {
                        if let list = vm.list {
                            ForEach(list.places) { place in
                                PlaceItem(place: place, vm: vm)
                            }
                        }
                    }
                    .redacted(reason: vm.list == nil ? .placeholder : [])
                    .padding()
                }
                .tag(PlacesListVM.Tabs.list)
                
                VStack {
                    if let list = vm.list {
                        Group {
                            if #available(iOS 17.0, *) {
                                CheckinsMap17(list: list)
                            } else {
                                CheckinsMap16(list: list)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .tag(PlacesListVM.Tabs.map)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbar {
            if let list = vm.list, let currentUser = Authentication.shared.currentUser, list.owner.id == currentUser.id {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        actionManager.value = [
                            .init(title: "Edit", callback: {
                                if let list = vm.list {
                                    vm.editingList = list
                                }
                            }),
                            .init(title: "Delete this list", alertMessage: "Are you sure you want to delete this list?", callback: {
                                Task {
                                    await vm.deleteList()
                                    dismiss()
                                }
                            })
                        ]
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .toolbarBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: Binding(optionalValue: $vm.editingList)) {
            if let list = vm.list {
                EditListView(originalList: list) { edited in
                    vm.list = edited
                    vm.editingList = nil
                } onCancel: {
                    vm.editingList = nil
                }
                
            }
        }
        .onDisappear {
            self.isAnimating = false
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}

fileprivate struct PlaceItem: View {
    @EnvironmentObject private var alertManager: AlertManager
    
    let place: UserPlacesList.ListPlace
    @ObservedObject var vm: PlacesListVM
    
    var body: some View {
        NavigationLink(value: AppRoute.place(id: place.place.id)) {
            VStack {
                HStack {
                    Text(place.place.name)
                        .cfont(.headline)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let list = vm.list, let currentUser = Authentication.shared.currentUser, list.collaborators.contains(where: { $0.user.id == currentUser.id && $0.access == .edit }) {
                        Button {
                            alertManager.value = .init(message: "Are you sure you want to remove this place from the list?", confirmationText: "Delete", role: .destructive, callback: {
                                Task {
                                    await vm.removePlaceFromList(placeId: place.place.id)
                                }
                            })
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text(DateFormatter.dateToShortString(date: place.createdAt))
                    
                    ProfileImage(place.user.profileImage, size: 28, cornerRadius: 14)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .padding()
            .background(Color.black.opacity(0.5))
            .background {
                if let thumbnail = place.place.thumbnail {
                    ImageLoader(thumbnail, contentMode: .fill) { progress in
                        Image(systemName: "arrow.down.circle.dotted")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Color.gray.opacity(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            Text("No Image")
                                .cfont(.title2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                }
            }
            .clipShape(.rect(cornerRadius: 16))
        }
        .foregroundStyle(Color.white)
    }
}

@available(iOS 17.0, *)
fileprivate struct CheckinsMap17: View {
    let list: UserPlacesList
    
    @State var position: MapCameraPosition = .automatic
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        Map(position: $position) {
            ForEach(list.places) { place in
                Annotation(place.place.name, coordinate: CLLocationCoordinate2D(latitude: place.place.location.geoLocation.lat, longitude: place.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: place.place.id)) {
                        ScalableMapAnnotation(scale: scale)
                    }
                }
            }
            
            UserAnnotation()
        }
        .onMapCameraChange(frequency: .onEnd, { mapCameraUpdateContext in
            scale = mapCameraUpdateContext.scaleValue
        })
    }
}

fileprivate struct CheckinsMap16: View {
    let list: UserPlacesList
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            annotationItems: list.places,
            annotationContent: { place in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: place.place.location.geoLocation.lat, longitude: place.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: place.place.id)) {
                        ScalableMapAnnotation(scale: scale)
                    }
                }
            }
        )
        .onAppear {
            if let last = list.places.last {
                mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: last.place.location.geoLocation.lat, longitude: last.place.location.geoLocation.lng), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
        }
        .onChange(of: mapRegion.span.latitudeDelta) { value in
            let scaleValue = 1.0 / value
            scale = scaleValue > 1 ? 1 : scaleValue < 0.4 ? 0.4 : scaleValue
        }
    }
}

#Preview {
    PlacesListView(listId: "")
}
