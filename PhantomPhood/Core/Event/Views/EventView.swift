//
//  EventView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/8/24.
//

import SwiftUI
import Kingfisher
import VideoPlayer
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
    @ObservedObject private var videoPlayerVM = VideoPlayerVM.shared
    @State private var videoTime: CMTime = .zero
    @State private var videoState: VideoPlayer.State? = nil
    @State private var videoTotalDuration: Double = .zero
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        if let thumbnail = vm.event?.place.thumbnail {
                            KFImage.url(thumbnail)
                                .placeholder {
                                    Image(systemName: "arrow.down.circle.dotted")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                }
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 80, height: 80)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color.themePrimary)
                        }
                        
                        VStack {
                            if let logo = vm.event?.logo {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.themeBorder.opacity(0.3), lineWidth: 2)
                                    
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
                                        .frame(width: 32, height: 32)
                                }
                                .frame(width: 36, height: 36)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Text(vm.event?.name ?? "Event Name")
                                .font(.custom(style: .title2))
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
                            .font(.custom(style: .body))
                            .foregroundStyle(.secondary)
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
                    .font(.custom(style: .body))
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
                    .font(.custom(style: .subheadline))
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
                        .font(.custom(style: .headline))
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
    }
    
    @ViewBuilder
    private func ExpandedMedia() -> some View {
        if let media = vm.expandedMedia {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                vm.expandedMedia = nil
                            }
                        }
                    
                    Group {
                        if media.type == .image, let url = media.src {
                            KFImage.url(url)
                                .placeholder {
                                    Rectangle()
                                        .foregroundStyle(Color.themePrimary)
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                                .loadDiskFileSynchronously()
                                .fade(duration: 0.25)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedGeometryEffect(id: media.id, in: namespace)
                                .frame(width: proxy.size.width, height: proxy.size.height + proxy.safeAreaInsets.top)
                                .contentShape(Rectangle())
                        } else if media.type == .video, let url = media.src {
                            ZStack(alignment: .bottom) {
                                VideoPlayer(url: url, play: Binding(get: {
                                    videoPlayerVM.playId == media.id
                                }, set: { value in
                                    if !value {
                                        videoPlayerVM.playId = nil
                                    } else {
                                        videoPlayerVM.playId = media.id
                                    }
                                }), time: $videoTime)
                                .onStateChanged { state in
                                    videoState = state
                                    switch state {
                                    case .playing(let totalDuration):
                                        videoTotalDuration = totalDuration
                                    default:
                                        break
                                    }
                                }
                                .autoReplay(true)
                                .mute(videoPlayerVM.isMute)
                                .contentMode(.scaleAspectFill)
                                .onAppear {
                                    videoPlayerVM.playId = media.id
                                }
                                .onDisappear {
                                    videoPlayerVM.playId = nil
                                }
                                
                                if let videoState, case .playing(_) = videoState {
                                    EmptyView()
                                } else if let videoState, case .error = videoState {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 50))
                                        .foregroundStyle(Color.red)
                                } else {
                                    if let thumbnail = media.thumbnail {
                                        KFImage.url(thumbnail)
                                            .loadDiskFileSynchronously()
                                            .fade(duration: 0.25)
                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .matchedGeometryEffect(id: media.id, in: namespace)
                                            .frame(width: proxy.size.width, height: proxy.size.height + proxy.safeAreaInsets.top)
                                            .grayscale(1)
                                            .overlay {
                                                ProgressView()
                                                    .controlSize(.large)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        if let user = media.user {
                            HStack(spacing: 5) {
                                ProfileImage(user.profileImage, size: 24, cornerRadius: 12)
                                
                                Text(user.name)
                                    .font(.custom(style: .caption2))
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
                            .font(.system(size: 22))
                            .frame(height: 24)
                        
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
                        .foregroundStyle(Color.themePrimary)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            VStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 22))
                                    .frame(height: 24)
                                
                                Text("Check In".uppercased())
                            }
                        }
                }
            } else {
                Button {
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themePrimary)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            VStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 22))
                                    .frame(height: 24)
                                
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
        if let event = vm.event, let url = URL(string: "https://phantomphood.ai/event/\(event.id)") {
            ShareLink(item: url, subject: Text(event.name), message: Text("Check out \(event.name) on Phantom Phood")) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                                .frame(height: 24)
                            
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
                                .font(.system(size: 22))
                                .frame(height: 24)
                            
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
