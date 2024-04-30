//
//  NewCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/25/24.
//

import SwiftUI
import PhotosUI

struct NewCheckinView: View {
    @StateObject private var pickerVM = PickerVM(limitToOne: true)
    
    @StateObject private var vm: NewCheckinVM
    
    init(_ idOrData: IdOrData<PlaceEssentials>, event: Event? = nil) {
        self._vm = StateObject(wrappedValue: NewCheckinVM(idOrData: idOrData, event: event))
    }
    
    init(mapPlace: MapPlace) {
        self._vm = StateObject(wrappedValue: NewCheckinVM(mapPlace: mapPlace))
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let error = vm.error {
                Text(error)
            } else {
                VStack (spacing: 0) {
                    VStack(spacing: 5) {
                        HStack {
                            if let thumbnail = vm.place?.thumbnail {
                                ImageLoader(thumbnail, contentMode: .fill) { _ in
                                    Image(systemName: "arrow.down.circle.dotted")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(alignment: .topTrailing) {
                                    if let event = vm.event, let logo = event.logo {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundStyle(Color.themePrimary)
                                            
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 24, height: 24)
                                                .foregroundStyle(Color.themeBG)
                                            
                                            ImageLoader(logo, contentMode: .fit) { _ in
                                                Image(systemName: "arrow.down.circle.dotted")
                                                    .foregroundStyle(Color.white.opacity(0.5))
                                            }
                                            .frame(width: 24, height: 24)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                        .frame(width: 30, height: 30)
                                        .offset(x: 5, y: -5)
                                    }
                                }
                            }
                            
                            VStack(spacing: 10) {
                                if let event = vm.event {
                                    Text(event.name)
                                        .font(.custom(style: .body))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                } else {
                                    Text(vm.place?.name ?? "Name Placeholder")
                                        .font(.custom(style: .body))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                }
                                Text(vm.place?.location.address ?? "Address Placeholder")
                                    .lineLimit(1)
                                    .foregroundStyle(.secondary)
                                    .font(.custom(style: .caption))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .redacted(reason: vm.place == nil ? .placeholder : [])
                        
                        Divider()
                    }
                    .background(Color.themePrimary)
                    
                    ScrollView {
                        VStack {
                            Text("No filters allowed - take a fun pic of you and your friends!")
                                .font(.custom(style: .headline))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            if pickerVM.mediaItems.isEmpty {
                                Menu {
                                    Button {
                                        vm.presentedSheet = .photosPicker
                                    } label: {
                                        Text("Choose From Library")
                                    }
                                    
                                    Button {
                                        vm.presentedSheet = .camera
                                    } label: {
                                        Text("Take a Photo")
                                    }
                                } label: {
                                    Label {
                                        Text("Add Photo")
                                            .fontWeight(.medium)
                                    } icon: {
                                        Image(systemName: "camera.fill")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .clipShape(.rect(cornerRadius: 10))
                                }
                                .controlSize(.large)
                                .disabled(vm.loadingSections.contains(.submitting))
                            } else {
                                HStack {
                                    Menu {
                                        Button {
                                            vm.presentedSheet = .photosPicker
                                        } label: {
                                            Text("Choose From Library")
                                        }
                                        
                                        Button {
                                            vm.presentedSheet = .camera
                                        } label: {
                                            Text("Take a Photo")
                                        }
                                    } label: {
                                        HStack {
                                            ForEach(pickerVM.mediaItems) { item in
                                                switch item.state {
                                                case .empty:
                                                    VStack {
                                                        Text("Loading")
                                                            .font(.custom(style: .caption))
                                                        
                                                        ProgressView()
                                                            .controlSize(.regular)
                                                    }
                                                case .loading:
                                                    VStack {
                                                        Text("Loading")
                                                            .font(.custom(style: .caption))
                                                        
                                                        ProgressView()
                                                            .controlSize(.regular)
                                                    }
                                                case .loaded(let mediaData):
                                                    switch mediaData {
                                                    case .image(let uiImage):
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(maxWidth: .infinity)
                                                            .clipShape(.rect(cornerRadius: 10))
                                                    case .movie(let url):
                                                        ReviewVideoView(url: url, mute: true)
                                                            .frame(width: 110, height: 140)
                                                            .clipShape(.rect(cornerRadius: 10))
                                                    }
                                                case .failure(let error):
                                                    Text("Error: \(error.localizedDescription)")
                                                        .frame(width: 110, height: 140)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .controlSize(.large)
                                    .disabled(vm.loadingSections.contains(.submitting))
                                    .frame(maxWidth: .infinity)
                                    
                                    VStack(alignment: .leading) {
                                        Group {
                                            if let first = pickerVM.mediaItems.first {
                                                if case .loaded(let mediaData) = first.state, case .image(let uiImage) = mediaData, first.source == .camera {
                                                    Button {
                                                        let imageSaver = ImageSaver { _, error, _ in
                                                            if error == nil {
                                                                withAnimation {
                                                                    vm.savedImageId = first.id
                                                                }
                                                            }
                                                        }
                                                        
                                                        imageSaver.writeToPhotoAlbum(uiImage: uiImage)
                                                    } label: {
                                                        if #available(iOS 17.0, *) {
                                                            Label(vm.savedImageId == first.id ? "Saved" : "Save to Library", systemImage: vm.savedImageId == first.id ? "checkmark.circle" : "square.and.arrow.down")
                                                                .contentTransition(.symbolEffect(.replace.upUp.byLayer))
                                                        } else {
                                                            Label(vm.savedImageId == first.id ? "Saved" : "Save to Library", systemImage: vm.savedImageId == first.id ? "checkmark.circle" : "square.and.arrow.down")
                                                        }
                                                    }
                                                    .foregroundStyle(vm.savedImageId == first.id ? Color.white : Color.accentColor)
                                                    
                                                    Divider()
                                                }
                                                
                                                Button {
                                                    withAnimation {
                                                        pickerVM.removeItem(first)
                                                    }
                                                } label: {
                                                    Label("Remove", systemImage: "minus.circle")
                                                }
                                            }
                                        }
                                        .controlSize(.large)
                                        
                                        Spacer()
                                    }
                                    .onDisappear {
                                        vm.savedImageId = nil
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .font(.custom(style: .body))
                        .padding()
                        .photosPicker(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckinVM.Sheets.photosPicker), selection: $pickerVM.selection, maxSelectionCount: 1, matching: .any(of: [.images]), photoLibrary: .shared())
                        .fullScreenCover(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckinVM.Sheets.camera)) {
                            CameraView(onCompletion: pickerVM.cameraHandler)
                        }
                        
                        Divider()
                            .padding(.bottom)
                        
                        TextField("Let us know what you're doing - make it as funny as you look (Optional)", text: $vm.caption, axis: .vertical)
                            .lineLimit(5...15)
                            .disabled(vm.loadingSections.contains(.submitting))
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.top)
                        
                        VStack {
                            if vm.mentions.isEmpty {
                                Text("Tag People (Find your fellow friends on the app and tag them!)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(Color.primary)
                                    .padding(.bottom, 8)
                            } else {
                                ForEach(vm.mentions) { user in
                                    MentionItem(vm: vm, user: user)
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    vm.presentedSheet = .userSelector
                                }
                            } label: {
                                HStack {
                                    Circle()
                                        .foregroundStyle(Color.themePrimary)
                                        .frame(width: 28, height: 28)
                                        .overlay {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    Text("Tag People")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .disabled(vm.loadingSections.contains(.submitting))
                            .foregroundStyle(Color.accentColor)
                        }
                        .padding()
                        
                        Divider()
                            .padding(.bottom)
                        
                        Section {
                            if vm.isAdvancedSettingsVisible {
                                Toggle(isOn: Binding(get: {
                                    return vm.privacyType == .PRIVATE
                                }, set: { value in
                                    if value {
                                        vm.privacyType = .PRIVATE
                                    } else {
                                        vm.privacyType = .PUBLIC
                                    }
                                })) {
                                    Text("Private Checkin")
                                }
                                .padding(.vertical)
                            }
                        } header: {
                            Button {
                                withAnimation {
                                    vm.isAdvancedSettingsVisible.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("Privacy")
                                        .foregroundStyle(Color.secondary)
                                    
                                    Spacer()
                                    
                                    Text(vm.isAdvancedSettingsVisible ? "Hide" : "Show")
                                    Image(systemName: vm.isAdvancedSettingsVisible ? "chevron.down" : "chevron.right")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 60)
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .scrollIndicators(.never)
                    .sheet(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: NewCheckinVM.Sheets.userSelector)) {
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
                    
                    VStack {
                        Divider()
                        
                        CTAButton {
                            Task {
                                HapticManager.shared.impact(style: .light)
                                await vm.submit(mediaItems: pickerVM.mediaItems)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                if vm.loadingSections.contains(.submitting) {
                                    ProgressView()
                                        .controlSize(.regular)
                                        .padding(.trailing, 3)
                                        .transition(AnyTransition.opacity)
                                }
                                
                                Text("Submit".uppercased())
                            }
                        }
                        .disabled(vm.loadingSections.contains(.placeInfo) || vm.loadingSections.contains(.submitting) || vm.error != nil)
                        .padding(.horizontal)
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .font(.custom(style: .body))
            }
        }
        .navigationTitle("Checking in")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct MentionItem: View {
    @ObservedObject var vm: NewCheckinVM
    let user: UserEssentials
    
    var body: some View {
        HStack {
            ProfileImage(user.profileImage, size: 28)
            
            Text(user.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                withAnimation {
                    vm.mentions.removeAll(where: { $0.id == user.id })
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(Color.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewCheckinView(.data(
            PlaceEssentials(
                id: "645c1d1ab41f8e12a0d166bc",
                name: "Eleven Madison Park",
                location: PlaceLocation(geoLocation: .init(lng: 40.7416519, lat: -73.9898102), address: "11 Madison Ave", city: "New York", state: "New York", country: "US", zip: "NY 10010"),
                thumbnail: nil,
                categories: ["food"]
            )
        ))
    }
}
