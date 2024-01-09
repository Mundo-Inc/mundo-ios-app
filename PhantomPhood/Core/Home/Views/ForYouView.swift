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
    
    @ObservedObject var commentsViewModel = CommentsViewModel.shared
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
            GeometryReader(content: { geometry in
                ZStack {
                    if !vm.items.isEmpty {
                        Pager(page: page, data: vm.items.indices, id: \.self) { index in
                            ForYouItem(index: index, forYouVM: vm, page: page, parentGeometry: geometry)
                                .if(index == 0, transform: { view in
                                    view
                                        .gesture(
                                            DragGesture()
                                                .onChanged({ value in
                                                    if page.index == 0 && value.location.y > value.startLocation.y {
                                                        draggedAmount = min(abs(value.translation.height) / dragAmountToRefresh, 1)
                                                        
                                                        if value.translation.height > dragAmountToRefresh {
                                                            if !self.haptic {
                                                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                                self.haptic = true
                                                            }
                                                        } else {
                                                            self.haptic = false
                                                        }
                                                    }
                                                })
                                                .onEnded({ value in
                                                    if value.translation.height > dragAmountToRefresh {
                                                        if !vm.isLoading && readyToReferesh {
                                                            Task {
                                                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                                await vm.getForYou(.refresh)
                                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
//                        .delaysTouches(false)
                        .bounces(false)
                        .vertical()
                        .onPageChanged({ pageIndex in
                            // set playId
                            if page.index >= 0 && vm.items.count >= pageIndex + 1 {
                                switch vm.items[pageIndex].resource {
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
                            
                            guard pageIndex >= vm.items.count - 5 else { return }
                            
                            if !vm.isLoading {
                                Task {
                                    await vm.getForYou(.new)
                                }
                            }
                        })
                        .overlay(alignment: .top) {
                            ProgressView(value: draggedAmount)
                                .opacity(draggedAmount < 0.1 ? 0 : draggedAmount * 0.5 + 0.5)
                        }
                        .environment(\.colorScheme, .dark)
                    } else {
                        ForYouItemPlaceholder(parentGeometry: geometry)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .home {
                        withAnimation {
                            page.update(.moveToFirst)
                        }
                        appData.tappedTwice = nil
                        if !vm.isLoading {
                            Task {
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
            if !vm.items.isEmpty, vm.items.endIndex >= page.index {
                let item = vm.items[page.index]
                switch item.resource {
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
        .onChange(of: vm.items.count) { count in
            if count > 0 && page.index == 0, let firstItem = vm.items.first {
                switch firstItem.resource {
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

#Preview {
    ForYouView(draggedAmount: .constant(.zero), dragAmountToRefresh: 250)
}
