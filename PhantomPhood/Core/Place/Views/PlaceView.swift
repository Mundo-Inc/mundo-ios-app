//
//  PlaceView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct PlaceView: View {
    let id: String
    
    @StateObject private var vm: PlaceViewModel
    
    init(id: String) {
        self.id = id
        self._vm = StateObject(wrappedValue: PlaceViewModel(id: id))
    }
    
    @State var isCollapsed = true
    @State var isHeaderCollapsed = true
    
    let descriptionPadding = 150
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
            
            ScrollView {
                Rectangle()
                    .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width - 100 : UIScreen.main.bounds.size.width + 100)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.themePrimary)
                    .overlay {
                        if let place = vm.place {
                            if !place.media.isEmpty {
                                TabView {
                                    ForEach(place.media) { media in
                                        switch media.type {
                                        case .image:
                                            if let url = URL(string: media.src) {
                                                AsyncImageLoader(url)
                                                    .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width - 100 : UIScreen.main.bounds.size.width + 100)
                                                    .frame(maxWidth: UIScreen.main.bounds.size.width)
                                            }
                                        case .video:
                                            ReviewVideoView(url: media.src)
                                                .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width - 100 : UIScreen.main.bounds.size.width + 100)
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
                                    AsyncImageLoader(thumbnailURL) {
                                        ProgressView()
                                    } errorView: {
                                        Label(
                                            title: { Text("Unable to load the image") },
                                            icon: { Image(systemName: "xmark.icloud") }
                                        )
                                        .foregroundStyle(.red)
                                    }
                                    .frame(height: isHeaderCollapsed ? UIScreen.main.bounds.size.width - 100 : UIScreen.main.bounds.size.width + 100)
                                    .frame(maxWidth: UIScreen.main.bounds.size.width)
                                    .clipped()
                                    .onTapGesture {
                                        withAnimation {
                                            isHeaderCollapsed.toggle()
                                        }
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
                    }
                    .overlay(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 86, height: 86)
                            .foregroundStyle(Color.themeBG)
                            .overlay {
                                if let place = vm.place {
                                    if let thumbnail = place.thumbnail, let thumbnailURL = URL(string: thumbnail) {
                                        AsyncImageLoader(thumbnailURL) {
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundStyle(Color.themePrimary)
                                        } errorView: {
                                            Label(
                                                title: { Text("Unable to load the image") },
                                                icon: { Image(systemName: "xmark.icloud") }
                                            )
                                            .foregroundStyle(.red)
                                        }
                                        .frame(width: 80, height: 80)
                                        .clipShape(.rect(cornerRadius: 12))
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: 80, height: 80)
                                        .foregroundStyle(Color.themePrimary)
                                }
                            }
                            .padding(.leading)
                            .padding(.leading)
                            .offset(y: 30)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            
                        } label: {
                            Label {
                                Text("Add to list")
                                    .font(.custom(style: .subheadline))
                                    .foregroundStyle(Color.white)
                            } icon: {
                                Image(systemName: "star.square.on.square.fill")
                                    .foregroundStyle(Color.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .background(Color.accentColor)
                        .clipShape(.rect(cornerRadius: 5))
                        .padding(.all, 2)
                        .background(Color.themeBG)
                        .clipShape(.rect(cornerRadius: 6))
                        .foregroundStyle(.primary)
                        .frame(height: 40)
                        .padding(.trailing)
                        .offset(y: 20)
                        .redacted(reason: vm.place == nil ? .placeholder : [])
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
                
                VStack {
                    HStack {
                        ForEach(MyProfileActiveTab.allCases.indices, id: \.self) { i in
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
                                    .font(.footnote)
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
                    .padding(.bottom, 5)
                    Divider()
                }
                .padding(.vertical)
                
                Group {
                    switch vm.activeTab {
                    case .overview:
                        PlaceOverviewView(vm: vm)
                            .transition(.move(edge: .leading))
                    case .reviews:
                        PlaceReviewsView(placeId: id, vm: vm)
                            .transition(.opacity)
                    case .media:
                        Text("Media")
                            .transition(.move(edge: .trailing))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
            }
//            .ignoresSafeArea(edges: .top)
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
