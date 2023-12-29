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
    @StateObject var vm = ForYouViewModel()
    
    @ObservedObject private var forYouInfoVM = ForYouInfoVM.shared
    
    @ObservedObject var videoPlayerVM = VideoPlayerVM.shared
    @StateObject private var page: Page = .first()
    
    @State private var draggedAmount: CGSize = .zero
    @State private var readyToReferesh = true
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                ZStack {
                    if !vm.items.isEmpty {
                        Pager(page: page, data: vm.items) { item in
                            ForYouItem(data: item, itemIndex: vm.items.firstIndex(of: item), page: page, parentGeometry: geometry)
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            if page.index == 0 && value.location.y > value.startLocation.y {
                                                withAnimation {
                                                    draggedAmount = value.translation
                                                }
                                                if value.translation.height > geometry.safeAreaInsets.top + 60 {
                                                    if !vm.isLoading && readyToReferesh {
                                                        Task {
                                                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                            await vm.getForYou(.refresh)
                                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                                .offset(y: draggedAmount.height < geometry.safeAreaInsets.top + 60 ? draggedAmount.height : geometry.safeAreaInsets.top + 60)
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
                            ProgressView(value: min(abs(draggedAmount.height), geometry.safeAreaInsets.top + 60), total: geometry.safeAreaInsets.top + 60)
                                .opacity((abs(draggedAmount.height) / (geometry.safeAreaInsets.top + 60)) * 0.7 + 0.3)
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
    ForYouView()
}
