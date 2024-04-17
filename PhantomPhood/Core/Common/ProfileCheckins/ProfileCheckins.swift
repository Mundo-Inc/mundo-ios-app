//
//  ProfileCheckins.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/22/23.
//

import SwiftUI
import MapKit

struct ProfileCheckins: View {
    @StateObject private var vm: ProfileCheckinsVM
    
    init(userId: UserIdEnum? = nil) {
        self._vm = StateObject(wrappedValue: ProfileCheckinsVM(userId: userId))
    }
    
    var body: some View {
        ZStack {
            if let checkins = vm.checkins, !checkins.isEmpty {
                if vm.displayMode == .map {
                    Group {
                        if #available(iOS 17.0, *) {
                            CheckinsMap17(checkins: checkins)
                        } else {
                            CheckinsMap16(checkins: checkins)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(checkins) { item in
                        NavigationLink(value: AppRoute.place(id: item.place.id)) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text(item.place.name)
                                        .font(.custom(style: .subheadline))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(DateFormatter.dateToShortString(date: item.createdAt))
                                        .font(.custom(style: .caption))
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
                                .font(.custom(style: .caption))
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                if !vm.isLoading {
                    Text("No check-ins")
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

@available(iOS 17.0, *)
fileprivate struct CheckinsMap17: View {
    let checkins: [Checkin]
    
    @State var position: MapCameraPosition = .automatic
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        Map(position: $position) {
            ForEach(checkins) { checkin in
                Annotation(checkin.place.name, coordinate: CLLocationCoordinate2D(latitude: checkin.place.location.geoLocation.lat, longitude: checkin.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: checkin.place.id)) {
                        Circle()
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 30, height: 30)
                            .overlay {
                                ZStack {
                                    Circle()
                                        .stroke(Color.themePrimary)
                                    
                                    Image(systemName: "mappin")
                                        .foregroundStyle(.white)
                                }
                            }
                            .scaleEffect(scale)
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .continuous, { mapCameraUpdateContext in
            let scaleValue = 1.0 / mapCameraUpdateContext.region.span.latitudeDelta
            scale = scaleValue > 1 ? 1 : scaleValue < 0.4 ? 0.4 : scaleValue
        })
    }
}

fileprivate struct CheckinsMap16: View {
    let checkins: [Checkin]
    
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            annotationItems: checkins,
            annotationContent: { checkin in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: checkin.place.location.geoLocation.lat, longitude: checkin.place.location.geoLocation.lng)) {
                    NavigationLink(value: AppRoute.place(id: checkin.place.id)) {
                        Circle()
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 30, height: 30)
                            .overlay {
                                ZStack {
                                    Circle()
                                        .stroke(Color.themePrimary)
                                    
                                    Image(systemName: "mappin")
                                        .foregroundStyle(.white)
                                }
                            }
                            .scaleEffect(scale)
                    }
                }
            }
        )
        .onAppear {
            if let last = checkins.last {
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
    ProfileCheckins()
}
