//
//  PlaceView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/19/24.
//

import SwiftUI
import CoreMedia
import MapKit

struct PlaceView: View {
    @StateObject private var vm: PlaceVM
    
    init(id: String, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(id: id, action: action))
    }
    
    init(mapPlace: MapPlace, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(mapPlace: mapPlace, action: action))
    }
    
    @Namespace private var namespace
    
    @State private var interactingWithMap = false
    
    @AppStorage(K.UserDefaults.isMute) private var isMute = false
    
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
                                                    .cfont(.caption2)
                                                    .foregroundStyle(.tertiary)
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 15))
                        
                        Text(vm.place?.name ?? "Name placeholder")
                            .cfont(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    .redacted(reason: vm.place == nil ? .placeholder : [])
                    
                    // MARK: - Address a nd Open Status
                    HStack(alignment: .top) {
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
                        .cfont(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            if let place = vm.place {
                                if let googleResults = place.thirdParty.google, let openingHours = googleResults.openingHours {
                                    Button {
                                        withAnimation {
                                            vm.presentedSheet = .openningHours
                                        }
                                    } label: {
                                        if openingHours.openNow {
                                            Label {
                                                Text("Open Now")
                                            } icon: {
                                                Image(systemName: "clock.badge.checkmark")
                                            }
                                            .foregroundStyle(Color.accentColor)
                                        } else {
                                            Label {
                                                Text("Closed")
                                            } icon: {
                                                Image(systemName: "clock.badge.xmark")
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                
                                if let phone = (place.phone ?? place.thirdParty.yelp?.phone), let url = URL(string: "tel://\(phone)") {
                                    Button {
                                        UIApplication.shared.open(url)
                                    } label: {
                                        Label {
                                            Text("Call")
                                        } icon: {
                                            Image(systemName: "phone.fill.arrow.up.right")
                                        }
                                    }
                                    .foregroundStyle(Color.accentColor)
                                }
                            } else {
                                Label {
                                    Text("--------")
                                } icon: {
                                    Image(systemName: "clock.badge.checkmark")
                                }
                                .redacted(reason: .placeholder)
                                
                                Label {
                                    Text("Call")
                                } icon: {
                                    Image(systemName: "phone.fill.arrow.up.right")
                                }
                                .redacted(reason: .placeholder)
                            }
                        }
                        .cfont(.subheadline)
                        .fontWeight(.medium)
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
                                .foregroundStyle(.mundo)
                                .frame(height: 24)
                                .cfont(.title2)
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
                                
                                Image(.Logo.tpLogo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
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
                        .cfont(.caption)
                        .tag(PlaceVM.ScoresTab.googlePhantomYelp)
                        
                        ScoresView()
                            .tag(PlaceVM.ScoresTab.scores)
                        
                        ZStack {
                            if let place = vm.place {
                                if #available(iOS 17.0, *) {
                                    Map(initialPosition: .region(MKCoordinateRegion(center: place.location.coordinates, latitudinalMeters: 8000, longitudinalMeters: 8000))) {
                                        Annotation(place.name, coordinate: place.location.coordinates) {
                                            SimpleMapAnnotation()
                                        }
                                    }
                                } else {
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: place.location.coordinates, latitudinalMeters: 8000, longitudinalMeters: 8000)), annotationItems: [place]) { place in
                                        MapAnnotation(coordinate: place.location.coordinates) {
                                            SimpleMapAnnotation()
                                        }
                                    }
                                }
                            } else {
                                Rectangle()
                                    .foregroundStyle(Color.themePrimary)
                            }
                            
                            if interactingWithMap {
                                VStack(alignment: .trailing) {
                                    Spacer()
                                    
                                    Button {
                                        interactingWithMap = false
                                    } label: {
                                        Text("Exit")
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(Color.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                                            .cfont(.caption)
                                    }
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 8)
                                    .padding(.trailing, 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Rectangle()
                                    .foregroundStyle(Color.black.opacity(0.6))
                                    .overlay(alignment: .bottom) {
                                        Label {
                                            Text("Tap to start interacting")
                                        } icon: {
                                            Image(systemName: "hand.tap.fill")
                                        }
                                        .cfont(.caption)
                                        .foregroundStyle(Color.white)
                                        .padding(.bottom)
                                    }
                                    .onTapGesture {
                                        interactingWithMap = true
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(PlaceVM.ScoresTab.map)
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 170)
                    .frame(maxWidth: .infinity)
                    
                    // MARK: - Action Buttons
                    HStack {
                        MapButton
                        
                        Spacer()
                        
                        CheckInButton()
                        
                        Spacer()
                        
                        ReviewButton()
                        
                        Spacer()
                        
                        SaveButton
                    }
                    .symbolRenderingMode(.hierarchical)
                    .cfont(.subheadline)
                    .fontWeight(.bold)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vm.expandedMedia == nil {
                if let place = vm.place, let url = URL(string: "\(K.ENV.WebsiteURL)/place/\(place.id)") {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: url, subject: Text(place.name), message: Text("Check out \(place.name) on \(K.appName)"))
                    }
                }
            } else {
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
        .toolbarBackground(.hidden, for: .navigationBar)
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
                    ForEach(openingHours.weekdayDescriptions, id: \.self) { hour in
                        Text(hour)
                    }
                }
                .cfont(.body)
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
                    switch mixedMedia {
                    case .phantom(let media):
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
                    case .yelp(let string):
                        if let url = URL(string: string) {
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
                            .matchedGeometryEffect(id: string.hash, in: namespace)
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
                        .cfont(.headline)
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
    private func CheckInButton() -> some View {
        if let place = vm.place {
            NavigationLink(value: AppRoute.checkin(.data(.init(placeDetail: place)))) {
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
                .foregroundStyle(Color.black)
        }
    }
    
    @ViewBuilder
    private func ReviewButton() -> some View {
        if let place = vm.place {
            NavigationLink(value: AppRoute.review(.data(.init(placeDetail: place)))) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.accentColor)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 26))
                                .frame(height: 28)
                            
                            Text("REVIEW")
                        }
                    }
            }
            .foregroundStyle(Color.black)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.accentColor)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 26))
                            .frame(height: 28)
                        
                        Text("REVIEW")
                    }
                }
                .foregroundStyle(Color.black)
        }
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
                                .font(.system(size: 26))
                                .frame(height: 28)
                            
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
                                .font(.system(size: 28))
                                .frame(height: 26)
                            
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
                            .font(.system(size: 26))
                            .frame(height: 28)
                        
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
                            .font(.system(size: 26))
                            .frame(height: 28)
                        
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
}

private struct ScoreItem: View {
    let title: String
    let score: Double
    
    @State var show = false
    
    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: 140, alignment: .leading)
                .cfont(.body)
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
