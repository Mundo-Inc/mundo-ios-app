//
//  ForYouView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/15/23.
//

import SwiftUI
import SwiftUIPager

struct ForYouView: View {
    @ObservedObject var commentsViewModel: CommentsViewModel
    @StateObject var vm = ForYouViewModel()
    
    @ObservedObject var videoPlayerVM = VideoPlayerVM.shared
    @StateObject private var page: Page = .first()
    
    @State private var draggedAmount: CGSize = .zero
    @State private var readyToReferesh = true
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                ZStack {
                    Pager(page: page, data: vm.items) { item in
                        ForYouItem(data: item, itemIndex: vm.items.firstIndex(of: item), page: page, commentsViewModel: commentsViewModel, parentGeometry: geometry)
                            .gesture(
                                DragGesture()
                                .onChanged({ value in
                                    if page.index == 0 && value.location.y > value.startLocation.y {
                                        withAnimation {
                                            draggedAmount = value.translation
                                        }
                                        if value.translation.height > geometry.safeAreaInsets.top {
                                            if !vm.isLoading && readyToReferesh {
                                                Task {
                                                    await vm.getForYou(.refresh)
                                                    if draggedAmount != .zero {
                                                        readyToReferesh = false
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                            self.readyToReferesh = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                })
                                .onEnded({ value in
                                    if draggedAmount != .zero {
                                        withAnimation {
                                            draggedAmount = .zero
                                        }
                                    }
                                    readyToReferesh = true
                                })
                            )
                            .offset(y: draggedAmount.height * 1.4 < geometry.safeAreaInsets.top + 50 ? draggedAmount.height * 1.4 : geometry.safeAreaInsets.top + 50)
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
                    .background(alignment: .top) {
                        ProgressView(value: min(abs(draggedAmount.height) * 1.4, geometry.safeAreaInsets.top) , total: geometry.safeAreaInsets.top)
                            .opacity((abs(draggedAmount.height) * 1.4 / geometry.safeAreaInsets.top) * 0.7 + 0.3)
                    }
                    .environment(\.colorScheme, .dark)
                }
                .ignoresSafeArea(edges: .top)
            })
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                if vm.isLoading {
                    ProgressView()
                }
            }
        })
        .onDisappear {
            if videoPlayerVM.playId != nil {
                videoPlayerVM.playId = nil
            }
        }
        .onAppear {
            if page.index >= 0 && vm.items.count >= page.index + 1 {
                switch vm.items[page.index].resource {
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
    ForYouView(commentsViewModel: CommentsViewModel())
}
