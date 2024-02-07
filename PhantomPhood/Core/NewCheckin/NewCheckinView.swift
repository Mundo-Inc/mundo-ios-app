//
//  NewCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/25/24.
//

import SwiftUI
import PhotosUI

struct NewCheckinView: View {
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var pickerVM = PickerVM()
    
    @StateObject private var vm: NewCheckinVM
    
    init(_ idOrData: IdOrData<PlaceEssentials>) {
        self._vm = StateObject(wrappedValue: NewCheckinVM(idOrData: idOrData))
    }
    
    init(mapPlace: MapPlace) {
        self._vm = StateObject(wrappedValue: NewCheckinVM(mapPlace: mapPlace))
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    Text(vm.place?.name ?? "Name Placeholder")
                        .font(.custom(style: .headline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(vm.place?.location.address ?? "Address Placeholder")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .redacted(reason: vm.place == nil ? .placeholder : [])
                
                Divider()
                    .padding(.vertical)
                
                TextField("(Optional) - Caption", text: $vm.caption, axis: .vertical)
                    .lineLimit(5...15)
                    .disabled(vm.loadings.contains(.submitting))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.themePrimary)
                    }
                    .padding(.horizontal)
                
                VStack {
                    ForEach(vm.mentions) { user in
                        MentionItem(vm: vm, user: user)
                    }
                    Button {
                        withAnimation {
                            vm.isUserSelectorPresented = true
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
                    .disabled(vm.loadings.contains(.submitting))
                    .foregroundStyle(Color.accentColor)
                }
                .padding()
                
                Divider()
                
                VStack {
                    Text("Take a Selfie!")
                        .font(.custom(style: .headline))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Take a fun picture of you and your friends having a good time")
                        .font(.custom(style: .caption))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PhotosPicker(
                        selection: $pickerVM.selection,
                        maxSelectionCount: 1,
                        matching: .any(of: [.images]),
                        photoLibrary: .shared()
                    ) {
                        if pickerVM.mediaItems.isEmpty {
                            Label {
                                Text("Add Photo")
                                    .fontWeight(.medium)
                            } icon: {
                                Image(systemName: "camera.fill")
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.themeBG)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .clipShape(.rect(cornerRadius: 10))
                        } else {
                            ZStack(alignment: .topTrailing) {
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
                                                .aspectRatio(contentMode: .fill)
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
                                
                                Button {
                                    withAnimation {
                                        self.pickerVM.selection.removeAll()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.red)
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(Color.black.opacity(0.5)))
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                                .padding(.trailing, 5)
                                .padding(.top, 5)
                            }
                        }
                    }
                    .disabled(vm.loadings.contains(.submitting))
                    .controlSize(.large)
                    .padding(.top, 8)
                }
                .padding()
                
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
            }
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.never)
        .font(.custom(style: .body))
        .sheet(isPresented: $vm.isUserSelectorPresented, content: {
            if #available(iOS 17.0, *) {
                UserSelector(onSelect: { user in
                    if !vm.mentions.contains(where: { $0.id == user.id }) {
                        vm.mentions.append(user)
                    }
                    vm.isUserSelectorPresented = false
                }, onCancel: {
                    vm.isUserSelectorPresented = false
                })
                .presentationBackground(.thinMaterial)
            } else {
                UserSelector(onSelect: { user in
                    if !vm.mentions.contains(where: { $0.id == user.id }) {
                        vm.mentions.append(user)
                    }
                    vm.isUserSelectorPresented = false
                }, onCancel: {
                    vm.isUserSelectorPresented = false
                })
            }
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        await vm.submit(mediaItems: pickerVM.mediaItems)
                        dismiss()
                    }
                } label: {
                    HStack {
                        if vm.loadings.contains(.submitting) {
                            ProgressView()
                        }
                        
                        Text("Submit")
                    }
                }
                .disabled(vm.loadings.contains(.submitting))
                .font(.custom(style: .body))
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
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
                thumbnail: "",
                categories: ["food"]
            )
        ))
    }
}
