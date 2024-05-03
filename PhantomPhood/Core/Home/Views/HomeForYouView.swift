//
//  HomeForYouView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/15/23.
//

import SwiftUI
import SwiftUIPager

struct HomeForYouView: View {
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var vm: HomeVM
    
    init(vm: HomeVM) {
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    @StateObject private var page: Page = .first()
    
    @State private var readyToReferesh = true
    @State private var haptic = false
    
    var body: some View {
        ZStack {
            if !vm.forYouItems.isEmpty {
                Pager(page: page, data: vm.forYouItems.indices, id: \.self) { index in
                    HomeActivityItem(item: $vm.forYouItems[index], vm: vm, forTab: .forYou)
                        .if(index == 0, transform: { view in
                            view
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            if page.index == 0 && value.location.y > value.startLocation.y {
                                                vm.draggedAmount = min(abs(value.translation.height) / HomeVM.dragAmountToRefresh, 1)
                                                
                                                if value.translation.height > HomeVM.dragAmountToRefresh {
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
                                            if value.translation.height > HomeVM.dragAmountToRefresh {
                                                if !vm.loadingSections.contains(.fetchingForYouData) && readyToReferesh {
                                                    Task {
                                                        HapticManager.shared.impact(style: .light)
                                                        await vm.updateForYouData(.refresh)
                                                        HapticManager.shared.notification(type: .success)
                                                    }
                                                }
                                            }
                                            
                                            if vm.draggedAmount != .zero {
                                                withAnimation {
                                                    vm.draggedAmount = .zero
                                                }
                                            }
                                            readyToReferesh = true
                                        })
                                )
                                .blur(radius: vm.draggedAmount < 0.1 ? 0 : vm.draggedAmount * 8)
                        })
                }
                .singlePagination()
                .pagingPriority(.simultaneous)
                .bounces(false)
                .vertical()
                .onPageChanged({ pageIndex in
                    if !vm.forYouItems.isEmpty && pageIndex >= 0 {
                        vm.forYouItemOnViewPort = vm.forYouItems[pageIndex].id
                    }
                    
                    guard pageIndex >= vm.forYouItems.count - 5 else { return }
                    
                    Task {
                        await vm.updateForYouData(.new)
                    }
                })
                .overlay(alignment: .top) {
                    ProgressView(value: vm.draggedAmount)
                        .opacity(vm.draggedAmount < 0.1 ? 0 : vm.draggedAmount * 0.5 + 0.5)
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .home && appData.homeActiveTab == .forYou {
                        withAnimation {
                            page.update(.moveToFirst)
                        }
                        appData.tappedTwice = nil
                        if !vm.loadingSections.contains(.fetchingForYouData) {
                            Task {
                                HapticManager.shared.impact(style: .light)
                                await vm.updateForYouData(.refresh)
                                HapticManager.shared.notification(type: .success)
                            }
                        }
                    }
                }
            } else {
                HomeActivityItemPlaceholder()
                    .ignoresSafeArea(edges: .top)
            }
        }
        .onAppear {
            if vm.scrollForYouToItem == nil {
                vm.scrollForYouToItem = { id in
                    if let index = vm.forYouItems.firstIndex(where: { $0.id == id }) {
                        withAnimation {
                            self.page.index = index
                        }
                    }
                }
            }
        }
        .task {
            if vm.forYouItems.isEmpty {
                await vm.updateForYouData(.refresh)
            } else {
                await vm.updateForYouIfNeeded()
            }
            
            // Updateing `forYouItemOnViewPort` on first data load
            if !vm.forYouItems.isEmpty, vm.forYouItems.count >= page.index + 1 {
                vm.forYouItemOnViewPort = vm.forYouItems[page.index].id
            }
        }
    }
}

#Preview {
    HomeForYouView(vm: HomeVM())
}
