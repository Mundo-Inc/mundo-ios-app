//
//  ProfileCheckinsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/22/23.
//

import SwiftUI
import MapKit

struct ProfileCheckinsView: View {
    @StateObject private var vm: ProfileCheckinsVM
    
    init(userId: UserIdEnum? = nil) {
        self._vm = StateObject(wrappedValue: ProfileCheckinsVM(userId: userId))
    }
    
    var body: some View {
        Group {
            if let checkIns = vm.checkIns, !checkIns.isEmpty {
                if vm.displayMode == .map {
                    if #available(iOS 17.0, *) {
                        CheckinsMap17(checkIns: checkIns)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        CheckinsMap16(checkIns: checkIns)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List(checkIns) { item in
                        NavigationLink(value: AppRoute.place(id: item.place.id)) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text(item.place.name)
                                        .cfont(.subheadline)
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(DateFormatter.dateToShortString(date: item.createdAt))
                                        .cfont(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(spacing: 2) {
                                    Group {
                                        if let country = item.place.location.country, !country.isEmpty {
                                            if let city = item.place.location.city, !city.isEmpty {
                                                Text("\(country) | \(city)")
                                            } else {
                                                if let state = item.place.location.state, !state.isEmpty {
                                                    Text("\(country) | \(state)")
                                                } else {
                                                    Text(country)
                                                }
                                            }
                                        }
                                        if let address = item.place.location.address, !address.isEmpty {
                                            Text(address)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .cfont(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                if !vm.isLoading {
                    Text("No Check-Ins")
                } else {
                    ZStack {
                        Color.themeBG
                        
                        ProgressView()
                    }
                }
            }
        }
        .navigationTitle("Check-ins")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker(selection: $vm.displayMode) {
                    ForEach(ProfileCheckinsVM.DisplayModeEnum.allCases, id: \.self) { item in
                        Label(item.rawValue, systemImage: item.systemImage)
                    }
                } label: {
                    Label {
                        Text("Display")
                    } icon: {
                        Image(systemName: vm.displayMode.systemImage)
                    }
                }
            }
        }
    }
}

fileprivate struct CheckInCluster: Identifiable {
    let place: PlaceEssentials
    let checkIns: [CheckIn]
    
    init(checkIns: [CheckIn]) throws {
        guard !checkIns.isEmpty else {
            throw InitializationError.emptyArray(description: "checkIns array must contain at least one item.")
        }
        self.place = checkIns.first!.place
        self.checkIns = checkIns
    }
    
    var id: String {
        place.id
    }
    
    static func create(from items: [CheckIn]) -> [CheckInCluster] {
        /// placeId, activity
        var dict: [String: [CheckIn]] = [:]
        
        for item in items {
            if dict[item.place.id] == nil {
                dict[item.place.id] = [item]
            } else {
                dict[item.place.id]!.append(item)
            }
        }
        
        return dict.values.compactMap { try? CheckInCluster(checkIns: $0) }
    }
}

@available(iOS 17.0, *)
fileprivate struct CheckinsMap17: View {
    private let checkInCluster: [CheckInCluster]
    
    init(checkIns: [CheckIn]) {
        self.checkInCluster = CheckInCluster.create(from: checkIns)
    }
    
    @State private var position: MapCameraPosition = .automatic
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Map(position: $position) {
            ForEach(checkInCluster) { checkInCluster in
                Annotation(checkInCluster.place.name, coordinate: CLLocationCoordinate2D(latitude: checkInCluster.place.location.geoLocation.lat, longitude: checkInCluster.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: checkInCluster.place.id)) {
                        ScalableMapAnnotation(scale: scale, count: checkInCluster.checkIns.count)
                    }
                }
            }
            
            UserAnnotation()
        }
        .mapStyle(.standard(emphasis: .automatic, pointsOfInterest: .excludingAll))
        .onMapCameraChange(frequency: .onEnd, { mapCameraUpdateContext in
            scale = mapCameraUpdateContext.scaleValue
        })
    }
}

fileprivate struct CheckinsMap16: View {
    private let checkInCluster: [CheckInCluster]
    
    init(checkIns: [CheckIn]) {
        self.checkInCluster = CheckInCluster.create(from: checkIns)
    }
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            annotationItems: checkInCluster,
            annotationContent: { checkInCluster in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: checkInCluster.place.location.geoLocation.lat, longitude: checkInCluster.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: checkInCluster.place.id)) {
                        ScalableMapAnnotation(scale: scale, count: checkInCluster.checkIns.count)
                    }
                }
            }
        )
        .onAppear {
            if let last = checkInCluster.last {
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
    ProfileCheckinsView()
}
