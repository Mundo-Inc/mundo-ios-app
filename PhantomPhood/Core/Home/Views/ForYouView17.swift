//
//  ForYouView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/31/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct ForYouView17: View {
    @ObservedObject var appData = AppData.shared
    
    @ObservedObject var commentsViewModel = CommentsViewModel.shared
    @StateObject var vm = ForYouVM()
    
    @ObservedObject private var forYouInfoVM = ForYouInfoVM.shared
    
    @ObservedObject var videoPlayerVM = VideoPlayerVM.shared
    
    @State private var scrollPosition: String? = nil
    
    var body: some View {
        ZStack {
            if !vm.items.isEmpty {
                Color.clear
                    .onAppear {
                        if scrollPosition == nil {
                            if let first = vm.items.first {
                                scrollPosition = first.id
                            }
                        }
                    }
            }
            
            GeometryReader(content: { geometry in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        if !vm.items.isEmpty {
                            ForEach(vm.items.indices, id: \.self) { index in
                                ForYouItem17(index: index, forYouVM: vm, parentGeometry: geometry, scrollPosition: scrollPosition)
                                    .frame(width: geometry.size.width, height: geometry.size.height + geometry.safeAreaInsets.top)
                                    .id(vm.items[index].id)
                            }
                        } else {
                            ForYouItemPlaceholder(parentGeometry: geometry)
                                .frame(width: geometry.size.width, height: geometry.size.height + geometry.safeAreaInsets.top)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollPosition)
                .ignoresSafeArea(edges: .top)
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.never)
                .environment(\.colorScheme, .dark)
                .refreshable {
                    await vm.getForYou(.refresh)
                }
                .onChange(of: scrollPosition) { newValue in
                    if let scrollPosition = newValue {
                        guard let itemIndex = vm.items.firstIndex(where: { $0.id == scrollPosition }) else { return }
                        
                        switch vm.items[itemIndex].resource {
                        case .review(let feedReview):
                            if let first = feedReview.videos.first, videoPlayerVM.playId != first.id {
                                videoPlayerVM.playId = first.id
                            } else if videoPlayerVM.playId != nil {
                                videoPlayerVM.playId = nil
                            }
                        default:
                            break
                        }
                        
                        guard itemIndex >= vm.items.count - 5 else { return }
                        
                        if !vm.isLoading {
                            Task {
                                await vm.getForYou(.new)
                            }
                        }
                    }
                }
                .onChange(of: appData.tappedTwice) {
                    if appData.tappedTwice == .home {
                        if let first = vm.items.first {
                            withAnimation {
                                scrollPosition = first.id
                            }
                        }
                        appData.tappedTwice = nil
                        Task {
                            if !vm.isLoading {
                                await vm.getForYou(.refresh)
                            }
                        }
                    }
                }
            })
        }
        .sheet(isPresented: Binding(optionalValue: $forYouInfoVM.data), onDismiss: {
            forYouInfoVM.reset()
        }) {
            if #available(iOS 17.0, *) {
                ForYouInfoView()
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.medium, .large])
            } else {
                ForYouInfoView()
                    .presentationDetents([.medium, .large])
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
        .onDisappear {
            if videoPlayerVM.playId != nil {
                videoPlayerVM.playId = nil
            }
        }
        .onAppear {
            if let scrollPosition {
                guard let itemIndex = vm.items.firstIndex(where: { $0.id == scrollPosition }) else { return }
                
                switch vm.items[itemIndex].resource {
                case .review(let feedReview):
                    if let first = feedReview.videos.first, videoPlayerVM.playId != first.id {
                        videoPlayerVM.playId = first.id
                    } else if videoPlayerVM.playId != nil {
                        videoPlayerVM.playId = nil
                    }
                default:
                    break
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ForYouView17()
}
