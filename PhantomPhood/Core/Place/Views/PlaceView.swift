//
//  PlaceView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI
import Kingfisher

struct PlaceView: View {
    let id: String
    let action: PlaceAction?
    
    @StateObject private var vm: PlaceViewModel
    
    init(id: String, action: PlaceAction? = nil) {
        self.id = id
        self.action = action
        self._vm = StateObject(wrappedValue: PlaceViewModel(id: id, action: action))
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
                        
                    } label: {
                        Label {
                            Text("Add to list")
                                .foregroundStyle(Color.white)
                        } icon: {
                            Image(systemName: "star.square.on.square.fill")
                                .foregroundStyle(Color.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay {
                            ZStack {
                                Color.black.opacity(0.7)
                                Text("Coming Soon")
                            }
                        }
                    }
                    .disabled(true) // TODO:
                    .font(.custom(style: .subheadline))
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
                
                VStack {
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
                            .transition(.slide)
                    case .reviews:
                        PlaceReviewsView(placeId: id, vm: vm)
                            .transition(.slide)
                    case .media:
                        PlaceMediaView(placeId: id, vm: vm)
                            .transition(.slide)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
            }
            .ignoresSafeArea(edges: .top)
            
            Button {
                vm.showActions = true
            } label: {
                Circle()
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    .rotationEffect(vm.showActions ? .degrees(135) : .zero)
                    .scaleEffect(vm.showActions ? 2 : 1)
                    .opacity(vm.showActions ? 0 : 1)
                    .offset(y: vm.showActions ? 50 : 0)
                    .animation(.bouncy, value: vm.showActions)
                    .padding(.trailing)
                    .padding(.bottom)
            }
            
            if vm.reportId != nil {
                ReportView(id: $vm.reportId, type: .review)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: vm.reportId)
            }
        }
        .toolbarBackground(.hidden, for: .automatic)
        .fullScreenCover(isPresented: $vm.showAddReview) {
            AddReviewView(placeVM: vm)
        }
        .sheet(isPresented: $vm.showActions) {
            VStack {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 30, height: 3)
                    .padding(.top)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Button {
                    Task {
                        await vm.checkin()
                    }
                    vm.showActions = false
                } label: {
                    HStack {
                        Image(systemName: "checkmark.diamond")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Check-in")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Check in to here")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Button {
                    vm.showActions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        vm.showAddReview = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Review")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Add a review to to this place")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .presentationDetents([.height(250)])
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
