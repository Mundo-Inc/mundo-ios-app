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
    
    @ObservedObject var commentsViewModel = CommentsVM.shared
    @StateObject var vm = ForYouVM()
    
    @ObservedObject private var forYouInfoVM = ForYouInfoVM.shared
    
    @ObservedObject var videoPlayerVM = VideoPlayerVM.shared
    
    @State private var scrollPosition: String? = nil
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                if !vm.items.isEmpty {
                    ForEach($vm.items) { $item in
                        ForYouItem17(item: $item, forYouVM: vm, scrollPosition: $scrollPosition)
                            .containerRelativeFrame(.vertical)
                            .id($item.wrappedValue.id)
                    }
                } else {
                    ForYouItemPlaceholder()
                        .containerRelativeFrame(.vertical)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollTargetLayout()
        }
        .refreshable {
            Task {
                await vm.getForYou(.refresh)
            }
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
        .onChange(of: vm.items.isEmpty) { isEmpty in
            if !isEmpty && scrollPosition == nil, let first = vm.items.first  {
                scrollPosition = first.id
            }
        }
        .onChange(of: scrollPosition) { newValue in
            if let scrollPosition = newValue {
                guard let itemIndex = vm.items.firstIndex(where: { $0.id == scrollPosition }) else { return }
                
                switch vm.items[itemIndex].resource {
                case .review(let feedReview):
                    if let first = feedReview.videos.first {
                        if let playId = videoPlayerVM.playId, playId != first.id {
                            videoPlayerVM.playId = first.id
                        } else if videoPlayerVM.playId == nil {
                            videoPlayerVM.playId = first.id
                        }
                    } else if videoPlayerVM.playId != nil {
                        videoPlayerVM.playId = nil
                    }
                case .homemade(let homemade):
                    if let first = homemade.media.first, first.type == .video {
                        if let playId = videoPlayerVM.playId, playId != first.id {
                            videoPlayerVM.playId = first.id
                        } else if videoPlayerVM.playId == nil {
                            videoPlayerVM.playId = first.id
                        }
                    } else if videoPlayerVM.playId != nil {
                        videoPlayerVM.playId = nil
                    }
                default:
                    if videoPlayerVM.playId != nil {
                        videoPlayerVM.playId = nil
                    }
                }
                
                guard itemIndex >= vm.items.count - 5 else { return }
                
                if !vm.isLoading {
                    Task {
                        await vm.getForYou(.new)
                    }
                }
            }
        }
        .onChange(of: appData.tappedTwice) { tapped in
            if tapped == .home && appData.homeActiveTab == .forYou {
                if let first = vm.items.first {
                    withAnimation(.bouncy(duration: 1)) {
                        scrollPosition = first.id
                    }
                }
                appData.tappedTwice = nil
                Task {
                    if !vm.isLoading {
                        HapticManager.shared.impact(style: .light)
                        await vm.getForYou(.refresh)
                        HapticManager.shared.notification(type: .success)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: Binding(optionalValue: $forYouInfoVM.data), onDismiss: {
            forYouInfoVM.reset()
        }) {
            ForYouInfoView()
                .presentationBackground(.thinMaterial)
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
                case .homemade(let homemade):
                    if let first = homemade.media.first, first.type == .video && videoPlayerVM.playId != first.id {
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
