//
//  HomeForYouView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/31/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct HomeForYouView17: View {
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var vm: HomeVM
    
    init(vm: HomeVM) {
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    @State private var scrollPosition: String? = nil
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                if !vm.forYouItems.isEmpty {
                    ForEach($vm.forYouItems) { $item in
                        HomeActivityItem(item: $item, vm: vm, forTab: .forYou)
                            .containerRelativeFrame(.vertical)
                            .id($item.wrappedValue.id)
                    }
                } else {
                    HomeActivityItemPlaceholder()
                        .containerRelativeFrame(.vertical)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollTargetLayout()
        }
        .refreshable {
            Task {
                await vm.updateForYouData(.refresh)
            }
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
        .onChange(of: vm.forYouItems.isEmpty) { isEmpty in
            if !isEmpty && scrollPosition == nil, let first = vm.forYouItems.first  {
                scrollPosition = first.id
            }
        }
        .onChange(of: scrollPosition) { newValue in
            if let scrollPosition = newValue {
                guard let itemIndex = vm.forYouItems.firstIndex(where: { $0.id == scrollPosition }) else { return }
                
                vm.forYouItemOnViewPort = vm.forYouItems[itemIndex].id
                
                guard itemIndex >= vm.forYouItems.count - 5 else { return }
                
                Task {
                    await vm.updateForYouData(.new)
                }
            }
        }
        .onChange(of: appData.tappedTwice) { tapped in
            if tapped == .home && appData.homeActiveTab == .forYou {
                if let first = vm.forYouItems.first {
                    withAnimation(.bouncy(duration: 1)) {
                        scrollPosition = first.id
                    }
                }
                appData.tappedTwice = nil
                Task {
                    if !vm.loadingSections.contains(.fetchingForYouData) {
                        HapticManager.shared.impact(style: .light)
                        await vm.updateForYouData(.refresh)
                        HapticManager.shared.notification(type: .success)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.themePrimary.ignoresSafeArea())
        .onAppear {
            if vm.scrollForYouToItem == nil {
                vm.scrollForYouToItem = { id in
                    withAnimation {
                        self.scrollPosition = id
                    }
                }
            }
        }
        .onDisappear {
            vm.forYouItemOnViewPort = nil
        }
        .task {
            if vm.forYouItems.isEmpty {
                await vm.updateForYouData(.refresh)
            } else {
                await vm.updateForYouIfNeeded()
            }
            
            if let scrollPosition, let itemIndex = vm.forYouItems.firstIndex(where: { $0.id == scrollPosition }) {
                vm.forYouItemOnViewPort = vm.forYouItems[itemIndex].id
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    HomeForYouView17(vm: HomeVM())
}
