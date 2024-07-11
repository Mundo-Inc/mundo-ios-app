//
//  EventView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import SwiftUI
import CoreMedia

struct EventView: View {
    @StateObject private var vm: EventVM
    
    init(_ idOrData: IdOrData<Event>) {
        switch idOrData {
        case .id(let id):
            self._vm = StateObject(wrappedValue: EventVM(id: id))
        case .data(let event):
            self._vm = StateObject(wrappedValue: EventVM(event: event))
        }
    }
    
    @Namespace private var namespace
    
    @AppStorage(K.UserDefaults.isMute) private var isMute = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        Group {
                            if let logo = vm.event?.logo {
                                ImageLoader(logo, contentMode: .fill) { progress in
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(maxWidth: 150)
                                        .overlay {
                                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .padding(.horizontal)
                                        }
                                }
                                .frame(width: 80, height: 80)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.themePrimary))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else if let thumbnail = vm.event?.place.thumbnail {
                                ImageLoader(thumbnail, contentMode: .fill) { progress in
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(maxWidth: 150)
                                        .overlay {
                                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .padding(.horizontal)
                                        }
                                }
                                .frame(width: 80, height: 80)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.themePrimary))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if vm.event?.logo != nil, let thumbnail = vm.event?.place.thumbnail {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color.themeBG)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(Color.themePrimary)
                                    
                                    ImageLoader(thumbnail, contentMode: .fit) { _ in
                                        Image(systemName: "arrow.down.circle.dotted")
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .frame(width: 36, height: 36)
                                .offset(x: 8, y: -8)
                            }
                        }
                        
                        VStack(spacing: 5) {
                            Text(vm.event?.name ?? "Event Name")
                                .cfont(.title2)
                                .fontWeight(.bold)
                                .redacted(reason: vm.event == nil ? .placeholder : [])
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    if let description = vm.event?.description {
                        Text(description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cfont(.body)
                            .foregroundStyle(.primary.opacity(0.8))
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Label(vm.event?.place.location.city ?? "City", systemImage: "mappin.circle")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(vm.event?.place.location.address ?? "Address")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .redacted(reason: (vm.event?.place.location.city == nil || vm.event?.place.location.address == nil) ? .placeholder : [])
                    .foregroundStyle(.secondary)
                    .cfont(.body)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        
                        MapButton
                        
                        CheckInButton()
                        
                        ShareButton()
                        
                        Spacer()
                    }
                    .frame(height: 80)
                    .symbolRenderingMode(.hierarchical)
                    .cfont(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .disabled(vm.event == nil)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Button {
                                vm.activeTab = .media
                            } label: {
                                Text("Media")
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(vm.activeTab == .media ? Color.accentColor : Color.secondary)
                            
                            Button {
                                vm.activeTab = .checkIns
                            } label: {
                                Text("Check Ins")
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(vm.activeTab == .checkIns ? Color.accentColor : Color.secondary)
                        }
                        .cfont(.headline)
                        .fontWeight(.medium)
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width / 2, height: 4)
                                .foregroundStyle(Color.accentColor)
                                .offset(x: vm.activeTab == .media ? 0 : UIScreen.main.bounds.width / 2)
                                .animation(.spring, value: vm.activeTab)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        switch vm.activeTab {
                        case .media:
                            EventMediaView(eventVM: vm, namespace: namespace)
                        case .checkIns:
                            EventCheckInsView(eventVM: vm)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            ExpandedMedia()
        }
        .background(Color.themeBG.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func ExpandedMedia() -> some View {
        if let media = vm.expandedMedia {
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            vm.expandedMedia = nil
                        }
                    }
                
                Group {
                    if media.type == .image, let url = media.src {
                        ImageLoader(url, contentMode: .fit) { progress in
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(maxWidth: 150)
                                .overlay {
                                    ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .padding(.horizontal)
                                }
                        }
                        .matchedGeometryEffect(id: media.id, in: namespace)
                    } else if media.type == .video, let url = media.src {
                        ZStack(alignment: .bottom) {
                            VideoPlayer(url: url, playing: true, isMute: isMute)
                        }
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    if let user = media.user {
                        HStack(spacing: 5) {
                            ProfileImage(user.profileImage, size: 24, cornerRadius: 12)
                            
                            Text(user.name)
                                .cfont(.caption2)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.leading, 5)
                        .padding(.bottom, 5)
                    }
                }
                .zIndex(2)
                .offset(vm.draggedAmount)
                .opacity(max(abs(vm.draggedAmount.width), abs(vm.draggedAmount.height)) >= 80 ? 0.5 : 1)
            }
            .zIndex(1)
            .ignoresSafeArea(edges: .top)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        vm.draggedAmount = value.translation
                    })
                    .onEnded({ value in
                        if max(abs(value.translation.width), abs(value.translation.height)) >= 80 {
                            withAnimation {
                                vm.expandedMedia = nil
                            }
                        }
                        withAnimation {
                            vm.draggedAmount = .zero
                        }
                    })
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            vm.expandedMedia = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private var MapButton: some View {
        Button {
            withAnimation {
                vm.presentedSheet = .navigationOptions
            }
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.themePrimary)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    VStack {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 26))
                            .frame(height: 28)
                        
                        Text("MAP")
                    }
                }
        }
        .foregroundStyle(Color.accentColor.opacity(0.85))
        .confirmationDialog("Directions", isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: EventVM.Sheets.navigationOptions), titleVisibility: .visible) {
            if let place = vm.event?.place {
                // Apple maps
                if let url = URL(string: "http://maps.apple.com/?q=\(place.name)&ll=\(place.location.geoLocation.lat),\(place.location.geoLocation.lng)") {
                    Link("Apple Maps", destination: url)
                }
                
                // Google maps
                if let url = URL(string: "comgooglemaps://?q=\(place.name)&center=\(place.location.geoLocation.lat),\(place.location.geoLocation.lng)&zoom=14&views=traffic") {
                    Link("Google Maps", destination: url)
                }
            }
        }
    }
    
    @ViewBuilder
    private func CheckInButton() -> some View {
        Group {
            if let event = vm.event {
                NavigationLink(value: AppRoute.checkin(.data(event.place), event)) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.accentColor)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            VStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 26))
                                    .frame(height: 28)
                                
                                Text("CHECK IN")
                            }
                        }
                }
                .foregroundStyle(Color.black)
            } else {
                Button {
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themePrimary)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            VStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 26))
                                    .frame(height: 28)
                                
                                Text("Check In".uppercased())
                            }
                        }
                }
            }
        }
        .foregroundStyle(Color.accentColor.opacity(0.85))
    }
    
    @ViewBuilder
    private func ShareButton() -> some View {
        if let event = vm.event, let url = URL(string: "\(K.ENV.WebsiteURL)/event/\(event.id)") {
            ShareLink(item: url, subject: Text(event.name), message: Text("Check out \(event.name) on \(K.appName)")) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 26))
                                .frame(height: 28)
                            
                            Text("SHARE")
                        }
                    }
            }
            .foregroundStyle(Color.accentColor.opacity(0.85))
        } else {
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 26))
                                .frame(height: 28)
                            
                            Text("SHARE")
                        }
                    }
            }
            .disabled(true)
            .foregroundStyle(Color.accentColor.opacity(0.85))
        }
    }
}

#Preview {
    EventView(.data(Event(
        id: "65eafc78b56154da574fc9fa",
        name: "AEπ",
        description: "Test description",
        logo: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/events/AEPi.png"),
        place: PlaceEssentials(
            id: "65eafc78b56154da574fc9f8",
            name: "AEπ",
            location: PlaceLocation(geoLocation: .init(lng: -122.0308473, lat: 36.9699794), address: "318 Maple St", city: "Santa Cruz", state: "CA", country: "US", zip: "95060"),
            thumbnail: URL(string: ""),
            categories: []
        )
    )))
}
