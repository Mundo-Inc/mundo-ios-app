//
//  PlaceView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import SwiftUI
import Kingfisher
import VideoPlayer
import CoreMedia

struct PlaceView: View {
    @StateObject private var vm: PlaceVM
    
    init(id: String, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(id: id, action: action))
    }
    
    init(mapPlace: MapPlace, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(mapPlace: mapPlace, action: action))
    }
    
    @Namespace private var namespace
    @ObservedObject private var videoPlayerVM = VideoPlayerVM.shared
    @State private var videoTime: CMTime = .zero
    @State private var videoState: VideoPlayer.State? = nil
    @State private var videoTotalDuration: Double = .zero
    
    var body: some View {
        ZStack {
            if vm.place != nil {
                Color.clear
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if self.vm.scoresTabView == .googlePhantomYelp {
                                withAnimation {
                                    self.vm.scoresTabView = .scores
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    if self.vm.scoresTabView == .scores {
                                        withAnimation {
                                            self.vm.scoresTabView = .googlePhantomYelp
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            
            ScrollView(.vertical) {
                VStack(spacing: 15) {
                    // MARK: - Header
                    HStack(spacing: 20) {
                        Group {
                            if let thumbnail = vm.place?.thumbnail {
                                KFImage.url(thumbnail)
                                    .placeholder {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(Color.themePrimary)
                                    }
                                    .loadDiskFileSynchronously()
                                    .fade(duration: 0.25)
                                    .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(Color.themePrimary)
                                    .overlay {
                                        if vm.place != nil {
                                            VStack {
                                                Image(systemName: "rectangle.on.rectangle.slash")
                                                    .foregroundStyle(.tertiary)
                                                    .font(.system(size: 28))
                                                
                                                Text("No Thumbnail")
                                                    .font(.custom(style: .caption2))
                                                    .foregroundStyle(.tertiary)
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 15))
                        .contentShape(RoundedRectangle(cornerRadius: 15))
                        
                        Text(vm.place?.name ?? "Name placeholder")
                            .font(.custom(style: .title2))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    .redacted(reason: vm.place == nil ? .placeholder : [])
                    
                    // MARK: - Address a nd Open Status
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            if let place = vm.place {
                                if let address = place.location.address {
                                    Text(address)
                                }
                                if let city = place.location.city {
                                    Text(city)
                                        .fontWeight(.bold)
                                }
                            } else {
                                Text("Address placeholder")
                                Text("City Placeholder")
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.custom(style: .body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Group {
                            if
                                let place = vm.place,
                                let googleResults = place.thirdParty.google,
                                let openingHours = googleResults.openingHours {
                                if openingHours.openNow {
                                    Label {
                                        Text("Open Now")
                                    } icon: {
                                        Image(systemName: "clock.badge.checkmark")
                                    }
                                    .foregroundStyle(Color.green)
                                } else {
                                    Label {
                                        Text("Closed")
                                    } icon: {
                                        Image(systemName: "clock.badge.xmark")
                                    }
                                    .foregroundStyle(.red)
                                }
                            } else if vm.place == nil {
                                Label {
                                    Text("--------")
                                } icon: {
                                    Image(systemName: "clock.badge.checkmark")
                                }
                                .redacted(reason: .placeholder)
                            }
                        }
                        .font(.custom(style: .subheadline))
                        .fontWeight(.medium)
                        .onTapGesture {
                            withAnimation {
                                vm.presentedSheet = .openningHours
                            }
                        }
                    }
                    .padding(.horizontal)
                    .redacted(reason: vm.place == nil ? .placeholder : [])
                    
                    // MARK: - Ratings
                    TabView(selection: $vm.scoresTabView) {
                        HStack {
                            VStack(spacing: 12) {
                                StarRating(score: vm.place?.thirdParty.google?.rating, activeColor: .gold)
                                    .frame(height: 24)
                                
                                Group {
                                    if let reviewCount = vm.place?.thirdParty.google?.reviewCount {
                                        Text("^[\(reviewCount) Review](inflect: true)")
                                    } else {
                                        Text("-- Reviews")
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .foregroundStyle(.secondary)
                                
                                Image(.googleLogo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 12) {
                                Group {
                                    if let phantomScore = vm.place?.scores.phantom {
                                        Text(String(format: "%.1f", phantomScore))
                                    } else {
                                        Text("TBD")
                                    }
                                }
                                .foregroundStyle(.phantom)
                                .frame(height: 24)
                                .font(.custom(style: .title2))
                                .fontWeight(.medium)
                                .redacted(reason: vm.place == nil ? .placeholder : [])
                                
                                Group {
                                    if let reviewCount = vm.place?.activities.reviewCount {
                                        Text("^[\(reviewCount) Review](inflect: true)")
                                    } else {
                                        Text("-- Reviews")
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .foregroundStyle(.secondary)
                                
                                Image(.phantomPortrait)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.phantom)
                                    .frame(height: 30)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 12) {
                                YelpRatingView(rating: vm.place?.thirdParty.yelp?.rating)
                                    .frame(maxHeight: 16)
                                    .frame(height: 24)
                                
                                Group {
                                    if let reviewCount = vm.place?.thirdParty.yelp?.reviewCount {
                                        Text("^[\(reviewCount) Review](inflect: true)")
                                    } else {
                                        Text("-- Reviews")
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .foregroundStyle(.secondary)
                                
                                Image(.yelpLogo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical)
                        .font(.custom(style: .caption))
                        .tag(PlaceVM.ScoresTab.googlePhantomYelp)
                        
                        ScoresView()
                            .tag(PlaceVM.ScoresTab.scores)
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // MARK: - Action Buttons
                    HStack {
                        MapButton
                        
                        Spacer()
                        
                        CallButton()
                        
                        Spacer()
                        
                        SaveButton
                        
                        Spacer()
                        
                        ShareButton()
                    }
                    .symbolRenderingMode(.hierarchical)
                    .font(.custom(style: .subheadline))
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .disabled(vm.place == nil)
                    
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
                                vm.activeTab = .reviews
                            } label: {
                                Text("Reviews")
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(vm.activeTab == .reviews ? Color.accentColor : Color.secondary)
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
                            PlaceMediaView(placeVM: vm, namespace: namespace)
                        case .reviews:
                            PlaceReviewsView(placeVM: vm)
                        }
                    }
                }
            }
            .scrollIndicators(.never)
            
            if let place = vm.place {
                /// place.thirdParty.google != nil
                /// place.thirdParty.google.openingHours != nil
                OpenningHours(place: place)
                
                // vm.expandedMedia != nil
                ExpandedMedia()
            }
        }
        .toolbarBackground(.hidden, for: .automatic)
    }
    
    @ViewBuilder
    private func OpenningHours(place: PlaceDetail) -> some View {
        if
            let googleResult = place.thirdParty.google,
            let openingHours = googleResult.openingHours,
            vm.presentedSheet == .openningHours {
            // MARK: - Openning Hours
            ZStack {
                Color.black.opacity(0.7)
                    .onTapGesture {
                        withAnimation {
                            vm.presentedSheet = nil
                        }
                    }
                
                VStack(alignment: .leading) {
                    ForEach(openingHours.weekdayText, id: \.self) { hour in
                        Text(hour)
                    }
                }
                .font(.custom(style: .body))
                .padding()
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 10))
            }
            .zIndex(1)
        }
    }
    
    @ViewBuilder
    private func ExpandedMedia() -> some View {
        if let mixedMedia = vm.expandedMedia {
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
                        switch mixedMedia {
                        case .phantom(let media):
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
                        case .yelp(let string):
                            if let url = URL(string: string) {
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
                                    .matchedGeometryEffect(id: string.hash, in: namespace)
                                    .frame(width: proxy.size.width, height: proxy.size.height + proxy.safeAreaInsets.top)
                                    .contentShape(Rectangle())
                                    .overlay(alignment: .bottomTrailing) {
                                        Image(.yelpLogo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 30)
                                            .padding(.leading, 5)
                                            .padding(.bottom, 5)
                                    }
                            }
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
    
    @ViewBuilder
    private func ScoresView() -> some View {
        VStack(spacing: 5) {
            if let place = vm.place {
                if place.scores.overall != nil || place.scores.atmosphere != nil || place.scores.drinkQuality != nil || place.scores.foodQuality != nil || place.scores.service != nil || place.scores.value != nil {
                    if let score = place.scores.overall {
                        ScoreItem(title: "Overall Score", score: score)
                    }
                    if let score = place.scores.drinkQuality {
                        ScoreItem(title: "Drink Quality", score: score)
                    }
                    if let score = place.scores.foodQuality {
                        ScoreItem(title: "Food Quality", score: score)
                    }
                    if let score = place.scores.service {
                        ScoreItem(title: "Service", score: score)
                    }
                    if let score = place.scores.atmosphere {
                        ScoreItem(title: "Atmosphere", score: score)
                    }
                    if let score = place.scores.value {
                        ScoreItem(title: "Value", score: score)
                    }
                } else {
                    Text("No Ratings Yet")
                        .font(.custom(style: .headline))
                        .foregroundStyle(.secondary)
                }
            } else {
                Group {
                    ScoreItem(title: "Overall Score", score: 0)
                    ScoreItem(title: "Drink Quality", score: 0)
                    ScoreItem(title: "Food Quality", score: 0)
                    ScoreItem(title: "Service", score: 0)
                    ScoreItem(title: "Atmosphere", score: 0)
                    ScoreItem(title: "Value", score: 0)
                }
                .redacted(reason: .placeholder)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func CallButton() -> some View {
        if let phone = (vm.place?.phone ?? vm.place?.thirdParty.yelp?.phone), let url = URL(string: "tel://\(phone)") {
            Button {
                UIApplication.shared.open(url)
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "phone.fill.arrow.up.right")
                                .font(.system(size: 22))
                                .frame(height: 24)
                            
                            Text("CALL")
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
                            Image(systemName: "phone.fill.arrow.up.right")
                                .font(.system(size: 22))
                                .frame(height: 24)
                            
                            Text("CALL")
                        }
                    }
            }
            .foregroundStyle(Color.accentColor.opacity(0.85))
            .disabled(true)
        }
    }
    
    private var SaveButton: some View {
        Button {
            withAnimation {
                vm.presentedSheet = .addToList
            }
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.themePrimary)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    VStack {
                        Image(systemName: (vm.includedLists?.isEmpty ?? true) ? "bookmark" : "bookmark.fill")
                            .opacity(0.8)
                            .font(.system(size: 22))
                            .frame(height: 24)
                        
                        Text((vm.includedLists?.isEmpty ?? true) ? "Save" : "Saved")
                    }
                }
        }
        .foregroundStyle(Color.accentColor.opacity(0.85))
        .fullScreenCover(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: PlaceVM.Sheets.addToList)) {
            if #available(iOS 16.4, *) {
                AddToListView(placeVM: vm)
                    .presentationBackground(.ultraThinMaterial)
            } else {
                AddToListView(placeVM: vm)
            }
        }
        .disabled(vm.includedLists == nil)
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
        .confirmationDialog("Directions", isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: PlaceVM.Sheets.navigationOptions), titleVisibility: .visible) {
            if let place = vm.place {
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
    private func ShareButton() -> some View {
        if let place = vm.place, let url = URL(string: "https://phantomphood.ai/place/\(place.id)") {
            ShareLink(item: url, subject: Text(place.name), message: Text("Check out \(place.name) on Phantom Phood")) {
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

private struct ScoreItem: View {
    let title: String
    let score: Double
    
    @State var show = false
    
    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: 140, alignment: .leading)
                .font(.custom(style: .body))
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
                .onAppear {
                    withAnimation {
                        self.show = true
                    }
                }
            
            AnimatedStarRating(score: score, size: 16, show: show)
        }
    }
}

#Preview {
    NavigationStack {
        PlaceView(id: "645c1d1ab41f8e12a0d166bc")
            .navigationTitle("Place")
            .navigationBarTitleDisplayMode(.inline)
    }
}
