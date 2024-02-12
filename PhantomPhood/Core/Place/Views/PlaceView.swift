//
//  PlaceView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI
import Kingfisher

struct PlaceView: View {
    @StateObject private var vm: PlaceVM
    
    init(id: String, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(id: id, action: action))
    }
    
    init(mapPlace: MapPlace, action: PlaceAction? = nil) {
        self._vm = StateObject(wrappedValue: PlaceVM(mapPlace: mapPlace, action: action))
    }
    
    @State var isCollapsed = true
    @State var isHeaderCollapsed = true
    
    let descriptionPadding = 150
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.themeBG.ignoresSafeArea()
            
            ScrollView {
                ZStack {
                    Rectangle()
                        .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width + 150)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.themePrimary)
                    
                    if let place = vm.place {
                        if !place.media.isEmpty {
                            TabView {
                                ForEach(place.media) { media in
                                    switch media.type {
                                    case .image:
                                        if let url = URL(string: media.src) {
                                            KFImage.url(url)
                                                .placeholder {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .foregroundStyle(Color.themePrimary)
                                                }
                                                .loadDiskFileSynchronously()
                                                .cacheMemoryOnly()
                                                .fade(duration: 0.25)
                                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width + 150)
                                                .frame(maxWidth: UIScreen.main.bounds.size.width)
                                                .contentShape(Rectangle())
                                        }
                                    case .video:
                                        ReviewVideoView(url: media.src, mute: true)
                                            .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width + 150)
                                            .frame(maxWidth: UIScreen.main.bounds.size.width)
                                    }
                                    
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    isHeaderCollapsed.toggle()
                                }
                            }
                            .tabViewStyle(.page)
                        } else {
                            if let thumbnail = place.thumbnail, let thumbnailURL = URL(string: thumbnail) {
                                ZStack {
                                    KFImage.url(thumbnailURL)
                                        .placeholder {
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundStyle(Color.themePrimary)
                                        }
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.width + 150)
                                        .frame(maxWidth: UIScreen.main.bounds.size.width)
                                        .clipped()
                                        .onTapGesture {
                                            withAnimation {
                                                isHeaderCollapsed.toggle()
                                            }
                                        }
                                        .contentShape(Rectangle())
                                }
                            } else {
                                Label(
                                    title: { Text("No thumbnail available") },
                                    icon: { Image(systemName: "photo") }
                                )
                            }
                        }
                    } else {
                        ProgressView()
                    }
                    
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 86, height: 86)
                        .foregroundStyle(Color.themeBG)
                        .overlay {
                            if let place = vm.place {
                                if let thumbnail = place.thumbnail, let thumbnailURL = URL(string: thumbnail) {
                                    KFImage.url(thumbnailURL)
                                        .placeholder {
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundStyle(Color.themePrimary)
                                        }
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(.rect(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: 80, height: 80)
                                        .foregroundStyle(Color.themePrimary)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundStyle(.tertiary)
                                        }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color.themePrimary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.leading)
                        .padding(.leading)
                        .offset(y: 30)
                    
                    Button {
                        withAnimation {
                            vm.isAddToListPresented = true
                        }
                    } label: {
                        Label {
                            Text((vm.includedLists?.isEmpty ?? true) ? "Add to list" : "Saved")
                                .foregroundStyle(Color.white)
                        } icon: {
                            Image(systemName: (vm.includedLists?.isEmpty ?? true) ? "star.square.on.square" : "star.square.on.square.fill")
                                .foregroundStyle(Color.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .font(.custom(style: .subheadline))
                    .background((vm.includedLists?.isEmpty ?? true) ? Color.accentColor : Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 5))
                    .padding(.all, 2)
                    .background(Color.themeBG)
                    .clipShape(.rect(cornerRadius: 6))
                    .foregroundStyle(.primary)
                    .frame(height: 40)
                    .padding(.trailing)
                    .offset(y: 20)
                    .redacted(reason: vm.includedLists == nil ? .placeholder : [])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                
                Spacer()
                    .frame(height: 40)
                
                HStack {
                    Text(vm.place?.name ?? "The Place Name")
                    
                    Spacer()
                    
                    Text(String(repeating: "$", count: vm.place?.priceRange ?? 3))
                        .fontWeight(.regular)
                }
                .redacted(reason: vm.place == nil ? .placeholder : [])
                .font(.custom(style: .headline))
                .padding(.horizontal)
                
                if let place = vm.place, let description = place.description, description.count > 0 {
                    Group {
                        Text("\(description.padding(toLength: isCollapsed ? descriptionPadding : description.count, withPad: "", startingAt: 0))\(description.count > descriptionPadding && isCollapsed ? "..." : "")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                        
                        if description.count > descriptionPadding {
                            Button {
                                withAnimation {
                                    isCollapsed.toggle()
                                }
                            } label: {
                                Label {
                                    Text(isCollapsed ? "Expand" : "Show less")
                                } icon: {
                                    Image(systemName: isCollapsed ? "rectangle.expand.vertical" : "chevron.up")
                                }
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                        }
                    }
                    .font(.custom(style: .caption))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                }
                
                VStack(spacing: 0) {
                    HStack {
                        ForEach(PlaceTab.allCases.indices, id: \.self) { i in
                            Button {
                                vm.prevActiveTab = vm.activeTab
                                withAnimation {
                                    vm.activeTab = PlaceTab.allCases[i]
                                }
                            } label: {
                                Text(PlaceTab.allCases[i].rawValue)
                                    .foregroundStyle(
                                        vm.activeTab == PlaceTab.allCases[i] ? Color.accentColor : Color.secondary
                                    )
                                    .font(.custom(style: .footnote))
                                    .bold()
                                    .controlSize(.small)
                                    .textCase(.uppercase)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            if i != MyProfileActiveTab.allCases.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Divider()
                
                    Group {
                        if let id = vm.id {
                            switch vm.activeTab {
                            case .overview:
                                PlaceOverviewView(vm: vm)
                            case .reviews:
                                PlaceReviewsView(placeId: id, vm: vm)
                            case .media:
                                PlaceMediaView(placeId: id, vm: vm)
                            }
                        } else {
                            VStack {
                                Rectangle()
                                    .foregroundStyle(Color.themePrimary)
                                    .frame(height: 170)
                                
                                Text("****** *** ******")
                                    .font(.custom(style: .headline))
                                    .bold()
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                            .redacted(reason: .placeholder)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 60)
                    .transition(.slide)
                    
                }
                .padding(.top)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            
            if let place = vm.place, vm.includedLists != nil, vm.isAddToListPresented {
                AddToListView(placeVM: vm, placeId: place.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbarBackground(.hidden, for: .automatic)
        .toolbar {
            if let place = vm.place, let url = URL(string: "https://phantomphood.ai/place/\(place.id)") {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(place.name, item: url, subject: Text(place.name), message: Text("Check out \(place.name) on Phantom Phood"))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlaceView(id: "645c1d1ab41f8e12a0d166bc")
            .navigationTitle("Place Page")
            .navigationBarTitleDisplayMode(.inline)
    }
}
