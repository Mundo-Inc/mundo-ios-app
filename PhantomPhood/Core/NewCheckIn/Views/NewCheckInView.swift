//
//  NewCheckInView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/31/24.
//

import SwiftUI

struct NewCheckInView: View {
    static let mediaSize: CGSize = CGSize(width: 200, height: 300)
    
    @StateObject private var vm: NewCheckInVM
    
    @StateObject private var pickerVM = PickerVM()
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.dismiss) private var dismiss
    
    init(event: Event) {
        self._vm = StateObject(wrappedValue: NewCheckInVM(event: event))
    }
    
    init(_ placeIdentifier: PlaceIdentifier) {
        self._vm = StateObject(wrappedValue: NewCheckInVM(placeIdentifier: placeIdentifier))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            TabView(selection: $vm.tabSelection) {
                mediaAndCaptionView
                
                detailsView
                
                ratingView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                HStack(spacing: 12) {
                    CButton(size: .lg, variant: .secondary, cornerRadius: 50) {
                        switch vm.tabSelection {
                        case .mediaAndCaption:
                            dismiss()
                        case .details:
                            vm.tabSelection = .mediaAndCaption
                        case .rating:
                            vm.tabSelection = .details
                        }
                    } label: {
                        Text(vm.getSecondaryActionTitle())
                    }
                    
                    CButton(fullWidth: true, size: .lg, variant: .primary, cornerRadius: 50) {
                        switch vm.tabSelection {
                        case .mediaAndCaption:
                            vm.tabSelection = .details
                        case .details:
                            vm.tabSelection = .rating
                        case .rating:
                            Task {
                                HapticManager.shared.impact(style: .light)
                                await vm.submit(mediaItems: pickerVM.mediaItems)
                                dismiss()
                            }
                        }
                    } label: {
                        Text(vm.getPrimaryActionTitle(selctedMediaCount: pickerVM.mediaItems.count))
                    }
                }
                .padding(.horizontal)
            }
            .ignoresSafeArea(.keyboard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .photosPicker(
            isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckInVM.Sheets.photosPicker),
            selection: $pickerVM.selection,
            maxSelectionCount: 8,
            matching: .any(of: [.images, .videos]),
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckInVM.Sheets.camera)) {
            CameraView(onCompletion: pickerVM.cameraHandler)
        }
        .sheet(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckInVM.Sheets.userSelector)) {
            if #available(iOS 16.4, *) {
                UserSelectorView { user in
                    if !vm.mentions.contains(where: { $0.id == user.id }) {
                        vm.mentions.append(user)
                    }
                }
                .presentationBackground(.thinMaterial)
            } else {
                UserSelectorView { user in
                    if !vm.mentions.contains(where: { $0.id == user.id }) {
                        vm.mentions.append(user)
                    }
                }
            }
        }
    }
    
    private var header: some View {
        VStack {
            HStack {
                if let event = vm.event, let logo = event.logo {
                    ImageLoader(logo, contentMode: .fit) { _ in
                        Image(systemName: "arrow.down.circle.dotted")
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(spacing: 10) {
                    Text(vm.event?.name ?? vm.place?.name ?? "Name Placeholder")
                        .cfont(.body)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    Group {
                        if let place = vm.place {
                            if let address = place.location.address {
                                Text(address)
                            } else {
                                Text("Address placeholder")
                                    .redacted(reason: .placeholder)
                                    .onAppear {
                                        vm.updatePlaceLocationInfo()
                                    }
                            }
                        } else {
                            Text("Address placeholder")
                        }
                    }
                    .lineLimit(1)
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(vm.place?.thumbnail != nil ? Color.white.opacity(0.85) : Color.secondary)
                }
                .foregroundStyle(vm.place?.thumbnail != nil ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .redacted(reason: vm.place == nil ? .placeholder : [])
            
            Divider()
        }
        .frame(maxWidth: .infinity)
        .background {
            if let thumbnail = vm.place?.thumbnail {
                ImageLoader(thumbnail, contentMode: .fill) { _ in
                    Image(systemName: "arrow.down.circle.dotted")
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .ignoresSafeArea()
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
            }
        }
        .background(Color.themePrimary)
    }
    
    private var mediaAndCaptionView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CButton(variant: .primary, text: pickerVM.mediaItems.isEmpty ? "Add Media" : "Change Selection", systemImage: pickerVM.mediaItems.isEmpty ? "plus.square.dashed" : "plusminus.circle") {
                    vm.presentedSheet = .photosPicker
                }
                .padding(.horizontal)
                
                if pickerVM.mediaItems.isEmpty {
                    Button {
                        vm.presentedSheet = .photosPicker
                    } label: {
                        Image(.Images.personWithMedia)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .padding(.horizontal, 30)
                    }
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(pickerVM.mediaItems) { item in
                                ZStack {
                                    switch item.state {
                                    case .empty, .loading(_):
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.themePrimary)
                                        
                                        VStack {
                                            ProgressView()
                                            
                                            Text("Loading")
                                                .cfont(.caption)
                                        }
                                    case .loaded(let mediaData):
                                        switch mediaData {
                                        case .image(let uiImage):
                                            ImageWrapper(Image(uiImage: uiImage))
                                        case .movie(let url):
                                            ReviewVideoView(url: url, mute: true)
                                                .overlay {
                                                    Image(systemName: "play.rectangle.on.rectangle.fill")
                                                        .font(.system(size: 38))
                                                        .foregroundStyle(.tertiary)
                                                }
                                        }
                                    case .failure(let error):
                                        Text("Error: \(error.localizedDescription)")
                                    }
                                }
                                .padding(.all, 2)
                                .frame(width: Self.mediaSize.width, height: Self.mediaSize.height)
                                .allowsHitTesting(false)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.primary, lineWidth: 2)
                                }
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        pickerVM.removeItem(item)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(Color.red)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12))
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.white)
                                        }
                                        .frame(width: 26, height: 26)
                                    }
                                    .padding(.top, 8)
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .cfont(.subheadline)
                    .scrollIndicators(.never)
                    .frame(height: 300)
                }
                
                CTextField($vm.caption, placeholder: "Write a caption (Optional)", lengthLimit: 250, range: 6...12)
                    .padding()
            }
            .padding(.vertical)
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.interactively)
        .tag(NewCheckInVM.Tab.mediaAndCaption)
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Privacy Type")
                            .fontWeight(.bold)
                        
                        Text("Who can see your check-in?")
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CButton(variant: .ghost, text: vm.privacyType.title, systemImage: vm.privacyType.systemImage) {
                        switch vm.privacyType {
                        case .PUBLIC:
                            vm.privacyType = .PRIVATE
                        case .PRIVATE:
                            vm.privacyType = .PUBLIC
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tag People")
                            .fontWeight(.bold)
                        
                        Text("Did you share your experience with anyone")
                            .fixedSize(horizontal: false, vertical: true)
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CButton(variant: .ghost, text: "Tag People", systemImage: "person.badge.plus") {
                        vm.presentedSheet = .userSelector
                    }
                }
                
                if !vm.mentions.isEmpty {
                    VStack(spacing: 16) {
                        ForEach(vm.mentions) { user in
                           mentionItem(user: user)
                        }
                    }
                    .padding(.top, 10)
                }
                
                Divider()
            }
            .padding()
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
        .tag(NewCheckInVM.Tab.details)
    }
    
    private var ratingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(NewCheckInVM.RatingItem.allCases, id: \.self) { item in
                    ratingRow(item: item)
                }
            }
            .padding()
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.interactively)
        .tag(NewCheckInVM.Tab.rating)
    }
    
    private func ratingRow(item: NewCheckInVM.RatingItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .cfont(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        if vm.scores[item] != nil && vm.scores[item]! == i {
                            vm.scores.removeValue(forKey: item)
                        } else {
                            vm.scores[item] = i
                        }
                    } label: {
                        let shouldHighlight = vm.scores[item] != nil ? i <= vm.scores[item]! : false
                        let delay = Double(i) / 20
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(shouldHighlight ? Color.accentColor.opacity(0.4) : Color.themePrimary)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                if shouldHighlight {
                                    Image(.Icons.starFill)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 32)
                                        .foregroundStyle(Color.accentColor)
                                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0)).animation(.easeOut.delay(delay)))
                                } else {
                                    Image(.Icons.star)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 32)
                                        .foregroundStyle(Color.secondary)
                                        .transition(AnyTransition.opacity.animation(.easeIn.delay(delay + 0.4)))
                                }
                            }
                            .animation(.easeIn.delay(delay), value: shouldHighlight)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func mentionItem(user: UserEssentials) -> some View {
        HStack {
            ProfileImage(user.profileImage, size: 42)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                
                Text("@\(user.username)")
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                withAnimation {
                    vm.mentions.removeAll(where: { $0.id == user.id })
                }
            } label: {
                Image(systemName: "person.badge.minus")
                    .font(.system(size: 20))
            }
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let place = PlaceEssentials(
        id: "645c1d1ab41f8e12a0d166bc",
        name: "Eleven Madison Park",
        location: PlaceLocation(
            geoLocation: PlaceLocation.GeoLocation(lng: -73.9872074872255, lat: 40.7416907417333),
            address: nil,
            city: "New York",
            state: "NY",
            country: "US",
            zip: "10010"
        ),
        thumbnail: URL(string: "https://lh3.googleusercontent.com/p/AF1QipORpCE38GEBjvmFeP2fO3yrHfKLjVb_wswX-Y_N=s680-w680-h510"),
        categories: []
    )
    
    let event = Event(id: "662fa397516a809bf7b46f77", name: "Rich Ventures", description: "Lorem ipsum dolor sit amet.\nconsectetur adipiscing elit.\nsed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", logo: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/events/RichVenturesLogo.jpg"), place: place)
    
    return NewCheckInView(event: event)
}
