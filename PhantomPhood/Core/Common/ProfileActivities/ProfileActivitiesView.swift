//
//  ProfileActivitiesView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/22/23.
//

import SwiftUI

struct ProfileActivitiesView: View {
    @StateObject private var vm: ProfileActivitiesVM
    @StateObject private var mediasViewModel = MediasViewModel()
    
    @State private var reportId: String? = nil
    
    init(userId: UserIdEnum? = nil, activityType: ProfileActivitiesVM.FeedItemActivityType) {
        self._vm = StateObject(wrappedValue: ProfileActivitiesVM(userId: userId, activityType: activityType))
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .sheet(isPresented: Binding(optionalValue: $reportId)) {
                    ReportView(id: $reportId, type: .review)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: reportId)
                }
            
            ScrollView {
                if vm.isLoading && vm.data.isEmpty {
                    ProgressView()
                } else {
                    if vm.data.isEmpty {
                        Text("No activity")
                            .font(.custom(style: .body))
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(vm.data) { item in
                                Group {
                                    switch item.activityType {
                                    case .levelUp:
                                        FeedLevelUpView(data: item)
                                    case .following:
                                        FeedFollowingView(data: item)
                                    case .newReview:
                                        FeedReviewView(data: item, mediasViewModel: mediasViewModel, reportId: $reportId)
                                    case .newCheckin:
                                        FeedCheckinView(data: item)
                                    default:
                                        Text(item.activityType.rawValue)
                                    }
                                }
                                .padding(.horizontal)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(currentItem: item)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $vm.isactivityTypePresented, onDismiss: {
            Task {
                await vm.getActivities(.refresh)
            }
        }, content: {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button {
                        vm.isactivityTypePresented = false
                    } label: {
                        Text("Done")
                    }
                }
                
                Picker(selection: $vm.activityType, label: Text("Activity Type")) {
                    ForEach(ProfileActivitiesVM.FeedItemActivityType.allCases, id: \.self) { item in
                        Text(item.title).tag(item.rawValue)
                    }
                }
                .pickerStyle(.wheel)
            }
            .padding(.top)
            .padding(.horizontal)
            .presentationDetents([.height(200)])
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.isactivityTypePresented = true
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

#Preview {
    NavigationStack {
        ProfileActivitiesView(activityType: .all)
    }
}
