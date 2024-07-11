//
//  MyActivitiesView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/13/24.
//

import SwiftUI
import SwiftUIPager

struct MyActivitiesView: View {
    @ObservedObject var vm: MyProfileVM
    let selected: String?
    
    @State private var isActivityTypePresented = false
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                MyActivitiesView17(selected: selected)
            } else {
                MyActivitiesView16(selected: selected)
            }
        }
        .environmentObject(vm)
        .sheet(isPresented: $isActivityTypePresented) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button {
                        isActivityTypePresented = false
                    } label: {
                        Text("Done")
                    }
                }
                
                Picker(selection: $vm.activityType, label: Text("Activity Type")) {
                    ForEach(MyProfileVM.TypeOptions.allCases, id: \.self) { item in
                        Text(item.title)
                            .tag(item)
                    }
                }
                .pickerStyle(.wheel)
                .cfont(.body)
            }
            .padding(.top)
            .padding(.horizontal)
            .presentationDetents([.height(200)])
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isActivityTypePresented = true
                } label: {
                    HStack {
                        Text(vm.activityType.title)
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
fileprivate struct MyActivitiesView17: View {
    @EnvironmentObject private var vm: MyProfileVM
    @State private var scrollPosition: String?
    private let selected: String?
    
    init(selected: String? = nil) {
        self.selected = selected
    }
    
    func scrollTo(_ id: String) {
        self.scrollPosition = id
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                if !vm.posts.isEmpty {
                    ForEach($vm.posts) { $item in
                        ActivityItem(item: $item, vm: vm)
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
                await vm.getPosts(.refresh)
            }
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
        .onChange(of: scrollPosition) { scrollPosition in
            guard let scrollPosition,
                  let itemIndex = vm.posts.firstIndex(where: { $0.id == scrollPosition }) else { return }
            
            // Updateing `itemOnViewPort` on scroll
            vm.itemOnViewPort = vm.posts[itemIndex].id
            
            guard itemIndex >= vm.posts.count - 5 else { return }
            
            Task {
                await vm.getPosts(.new)
            }
        }
        .ignoresSafeArea()
        .toolbarBackground(.hidden, for: .navigationBar)
        .background(Color.themePrimary.ignoresSafeArea())
        .task {
            if vm.posts.isEmpty {
                await vm.getPosts(.refresh)
            }
            
            if let selected {
                scrollTo(selected)
            } else {
                scrollPosition = vm.posts.first?.id
            }
            
            // Updateing `itemOnViewPort` on first data load
            if let scrollPosition, let itemIndex = vm.posts.firstIndex(where: { $0.id == scrollPosition }) {
                vm.itemOnViewPort = vm.posts[itemIndex].id
            }
        }
    }
}

fileprivate struct MyActivitiesView16: View {
    @EnvironmentObject private var vm: MyProfileVM
    private let selected: String?
    
    init(selected: String? = nil) {
        self.selected = selected
    }
    
    @StateObject private var page: Page = .first()
    
    @State private var readyToReferesh = true
    @State private var haptic = false
    
    func scrollTo(_ id: String) {
        if let index = vm.posts.firstIndex(where: { $0.id == id }) {
            withAnimation {
                self.page.index = index
            }
        }
    }
    
    var body: some View {
        ZStack {
            if !vm.posts.isEmpty {
                Pager(page: page, data: vm.posts.indices, id: \.self) { index in
                    ActivityItem(item: $vm.posts[index], vm: vm)
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
                                                if !vm.activityLoadingSections.contains(.gettingPosts) && readyToReferesh {
                                                    Task {
                                                        HapticManager.shared.impact(style: .light)
                                                        await vm.getPosts(.refresh)
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
                    if !vm.posts.isEmpty && pageIndex >= 0 {
                        vm.itemOnViewPort = vm.posts[pageIndex].id
                    }
                    
                    guard pageIndex >= vm.posts.count - 5 else { return }
                    
                    Task {
                        await vm.getPosts(.new)
                    }
                })
                .overlay(alignment: .top) {
                    ProgressView(value: vm.draggedAmount)
                        .opacity(vm.draggedAmount < 0.1 ? 0 : vm.draggedAmount * 0.5 + 0.5)
                }
                .ignoresSafeArea(edges: .top)
            } else {
                HomeActivityItemPlaceholder()
                    .ignoresSafeArea(edges: .top)
            }
        }
        .task {
            if vm.posts.isEmpty {
                await vm.getPosts(.refresh)
            }
            
            if let selected {
                scrollTo(selected)
            }
            
            // Updateing `itemOnViewPort` on first data load
            if vm.posts.count >= page.index + 1 {
                vm.itemOnViewPort = vm.posts[page.index].id
            }
        }
    }
}

#Preview {
    MyActivitiesView(vm: MyProfileVM(), selected: nil)
}
