//
//  ForYouView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/15/23.
//

import SwiftUI
import SwiftUIPager

struct ForYouView: View {
    @ObservedObject var appData = AppData.shared
    
    @ObservedObject var commentsViewModel = CommentsVM.shared
    @StateObject var vm = ForYouVM()
    
    @ObservedObject private var forYouInfoVM = ForYouInfoVM.shared
    
    @ObservedObject var videoPlayerVM = VideoPlayerVM.shared
    @StateObject private var page: Page = .first()
    
    @Binding var draggedAmount: Double
    let dragAmountToRefresh: Double
    @State private var readyToReferesh = true
    @State private var haptic = false
    
    var body: some View {
        ZStack {
            if !vm.items.isEmpty {
                Pager(page: page, data: vm.items.indices, id: \.self) { index in
                    ForYouItem(index: index, forYouVM: vm, page: page)
                        .if(index == 0, transform: { view in
                            view
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            if page.index == 0 && value.location.y > value.startLocation.y {
                                                draggedAmount = min(abs(value.translation.height) / dragAmountToRefresh, 1)
                                                
                                                if value.translation.height > dragAmountToRefresh {
                                                    if !self.haptic {
                                                        HapticManager.shared.impact(style: .heavy)
                                                        self.haptic = true
                                                    }
                                                } else {
                                                    self.haptic = false
                                                }
                                            }
                                        })
                                        .onEnded({ value in
                                            if value.translation.height > dragAmountToRefresh {
                                                if !vm.loadingSections.contains(.fetchingData) && readyToReferesh {
                                                    Task {
                                                        HapticManager.shared.impact(style: .light)
                                                        await vm.getForYou(.refresh)
                                                        HapticManager.shared.notification(type: .success)
                                                    }
                                                }
                                            }
                                            
                                            if draggedAmount != .zero {
                                                withAnimation {
                                                    draggedAmount = .zero
                                                }
                                            }
                                            readyToReferesh = true
                                        })
                                )
                                .blur(radius: draggedAmount < 0.1 ? 0 : draggedAmount * 8)
                        })
                }
                .singlePagination()
                .pagingPriority(.simultaneous)
                .bounces(false)
                .vertical()
                .onPageChanged({ pageIndex in
                    // set playId
                    if page.index >= 0 && vm.items.count >= pageIndex + 1 {
                        switch vm.items[pageIndex].resource {
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
                    }
                    
                    guard pageIndex >= vm.items.count - 5 else { return }
                    
                    if !vm.loadingSections.contains(.fetchingData) {
                        Task {
                            await vm.getForYou(.new)
                        }
                    }
                })
                .overlay(alignment: .top) {
                    ProgressView(value: draggedAmount)
                        .opacity(draggedAmount < 0.1 ? 0 : draggedAmount * 0.5 + 0.5)
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .home {
                        withAnimation {
                            page.update(.moveToFirst)
                        }
                        appData.tappedTwice = nil
                        if !vm.loadingSections.contains(.fetchingData) {
                            Task {
                                HapticManager.shared.impact(style: .light)
                                await vm.getForYou(.refresh)
                                HapticManager.shared.notification(type: .success)
                            }
                        }
                    }
                }
            } else {
                ForYouItemPlaceholder()
                    .ignoresSafeArea(edges: .top)
            }
        }
        .environment(\.colorScheme, .dark)
        .sheet(isPresented: Binding(optionalValue: $forYouInfoVM.data), onDismiss: {
            forYouInfoVM.reset()
        }) {
            Group {
                if #available(iOS 16.4, *) {
                    ForYouInfoView()
                        .presentationBackground(.thinMaterial)
                } else {
                    ForYouInfoView()
                }
            }
        }
        .onDisappear {
            if videoPlayerVM.playId != nil {
                videoPlayerVM.playId = nil
            }
        }
        .onAppear {
            if !vm.items.isEmpty, vm.items.endIndex >= page.index {
                let item = vm.items[page.index]
                switch item.resource {
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
                    break
                }
            }
        }
        .onChange(of: vm.items.count) { count in
            if count > 0 && page.index == 0, let firstItem = vm.items.first {
                switch firstItem.resource {
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
                    break
                }
            }
        }
    }
}

#Preview {
    ForYouView(draggedAmount: .constant(.zero), dragAmountToRefresh: 250)
}
