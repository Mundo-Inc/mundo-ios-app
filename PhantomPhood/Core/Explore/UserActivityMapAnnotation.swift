//
//  UserActivityMapAnnotation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/3/24.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct UserActivityMapAnnotation: MapContent {
    let item: ClusteredMapActivity
    @EnvironmentObject private var vm: ExploreVM17
    
    var body: some MapContent {
        if let event = item.event {
            Annotation(event.place.name, coordinate: event.place.coordinates) {
                ImageLoader(event.logo) { _ in
                    Image(systemName: "arrow.down.circle.dotted")
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .frame(width: 50, height: 50)
                .clipShape(.rect(cornerRadius: 5))
                .overlay(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color.themeBG)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Text("\(item.items.count)")
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                        .font(.custom(style: .caption2))
                        .offset(x: 5, y: -5)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    AppData.shared.goTo(.event(.data(event)))
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
        } else if let first = item.first {
            Annotation(first.place.name, coordinate: first.place.coordinates) {
                ZStack {
                    Group {
                        if vm.showSet.contains(item.id) {
                            Circle()
                                .stroke(LinearGradient(colors: [
                                    Color(hue: 29 / 360, saturation: 0.66, brightness: 0.96),
                                    Color(hue: 346 / 360, saturation: 0.73, brightness: 0.94),
                                ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3.5)
                                .frame(width: 54)
                                .shadow(radius: 5)
                            
                            Circle()
                                .foregroundStyle(Color.white)
                                .frame(width: 47)
                            
                            if item.items.count > 1 {
                                VStack(spacing: 0) {
                                    ProfileImageBase(first.user.profileImage, size: 24)
                                    
                                    Text(item.items.count >= 100 ? "99+" : "+\(item.items.count - 1)")
                                        .fontWeight(.semibold)
                                        .font(.custom(style: .caption2))
                                        .foregroundStyle(Color.white)
                                        .frame(height: 16.5)
                                }
                                .padding(.all, 1.5)
                                .frame(width: 43.5, height: 43.5)
                                .background(LinearGradient(colors: [
                                    Color(hue: 349 / 360, saturation: 0.71, brightness: 0.82),
                                    Color(hue: 22 / 360, saturation: 0.56, brightness: 0.86),
                                ], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                            } else {
                                ProfileImageBase(first.user.profileImage, size: 43.5)
                            }
                        }
                    }
                    .transition(AnyTransition.asymmetric(insertion: .scale.animation(.bouncy(duration: 0.5)), removal: .identity.animation(.easeIn(duration: 0))))
                }
                .frame(width: 56.5, height: 56.5)
                .scaleEffect(vm.scale - 0.25 + min(Double(item.items.count - 1) * 0.1, 0.5))
                .onTapGesture {
                    withAnimation {
                        if let latestMapContext = vm.latestMapContext {
                            let span = latestMapContext.region.span.latitudeDelta < 0.3 ? latestMapContext.region.span : .init(latitudeDelta: 0.2, longitudeDelta: 0.15)
                            vm.panToRegion(.init(center: first.place.coordinates, span: span).shiftCenter(yPercentage: -0.3))
                        } else {
                            vm.panToRegion(.init(center: first.place.coordinates, latitudinalMeters: 9000, longitudinalMeters: 9000).shiftCenter(yPercentage: -0.3))
                        }
                        
                        vm.presentedSheet = .activityCluster(item)
                    }
                }
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
}

@available(iOS 17.0, *)
#Preview {
    let place1 = PlaceEssentials(id: "Place1", name: "Place 1", location: .init(geoLocation: .init(lng: -73.9245, lat: 40.82125), address: nil, city: nil, state: nil, country: nil, zip: nil), thumbnail: nil, categories: [])
    let user1 = UserEssentials(id: "User1", name: "Name 1", username: "Username1", verified: false, profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"), progress: .init(level: 35, xp: 2000))
    
    let place2 = PlaceEssentials(id: "Place2", name: "Place 2", location: .init(geoLocation: .init(lng: -73.9345, lat: 40.81125), address: nil, city: nil, state: nil, country: nil, zip: nil), thumbnail: nil, categories: [])
    let user2 = UserEssentials(id: "User2", name: "Name 2", username: "Username2", verified: false, profileImage: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg"), progress: .init(level: 45, xp: 4000))
    
    return Map {
        UserActivityMapAnnotation(item: ClusteredMapActivity(items: [
            .init(
                id: "Activity1",
                place: place1,
                user: user1,
                activityType: "NEW_CHECKIN",
                createdAt: .now
            )
        ]))
        
        UserActivityMapAnnotation(item: ClusteredMapActivity(items: [
            .init(
                id: "Activity1",
                place: place2,
                user: user1,
                activityType: "NEW_CHECKIN",
                createdAt: .now
            ),
            .init(
                id: "Activity1",
                place: place2,
                user: user2,
                activityType: "NEW_CHECKIN",
                createdAt: .now
            )
        ]))
    }
    .environmentObject(ExploreVM17())
    
}
