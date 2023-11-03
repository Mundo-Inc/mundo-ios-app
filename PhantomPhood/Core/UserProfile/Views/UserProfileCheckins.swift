//
//  UserProfileCheckins.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import SwiftUI
import MapKit

struct UserProfileCheckins: View {
    @StateObject private var vm: UserProfileCheckinsVM
    
    init(userId: String) {
        self._vm = StateObject(wrappedValue: UserProfileCheckinsVM(userId: userId))
    }
    
    // Only used on iOS 16
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        Group {
            if let checkins = vm.checkins, !checkins.isEmpty {
                if #available(iOS 17.0, *) {
                    Map {
                        ForEach(checkins) { checkin in
                            Marker(checkin.place.name, coordinate: CLLocationCoordinate2D(latitude: checkin.place.location.geoLocation.lat, longitude: checkin.place.location.geoLocation.lng))
                        }
                    }
                } else {
                    Map(
                        coordinateRegion: $mapRegion,
                        annotationItems: checkins.map({ checkin in
                            MapLocation(name: checkin.place.name, coordinate: CLLocationCoordinate2D(latitude: checkin.place.location.geoLocation.lat, longitude: checkin.place.location.geoLocation.lng))
                        }),
                        annotationContent: { location in
                            MapMarker(coordinate: location.coordinate)
                        }
                    )
                    .onAppear(perform: {
                        if let last = checkins.last {
                            mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: last.place.location.geoLocation.lat, longitude: last.place.location.geoLocation.lng), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        }
                    })
                }
            } else {
                if !vm.isLoading {
                    Text("No checkins")
                } else {
                    ZStack {
                        Color.themeBG
                        ProgressView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await vm.getCheckins(type: .refresh)
            }
        }
    }
}

#Preview {
    UserProfileCheckins(userId: "645e7f843abeb74ee6248ced")
}
