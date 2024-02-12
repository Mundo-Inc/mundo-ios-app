//
//  UserActivityView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import SwiftUI

struct UserActivityView: View {
    let id: String
    
    @ObservedObject private var commentsViewModel = CommentsVM.shared
    
    @StateObject private var vm = UserActivityVM()
    @StateObject private var mediasViewModel = MediasVM()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.themeBG
                .ignoresSafeArea()
                .fullScreenCover(isPresented: $mediasViewModel.show, content: {
                    MediasView(vm: mediasViewModel)
                })
                .onAppear {
                    Task {
                        await vm.getActivity(id)
                    }
                }
            
            ScrollView {
                if let item = vm.data {
                    Group {
                        switch item.activityType {
                        case .levelUp:
                            UserActivityLevelUp(vm: vm)
                        case .following:
                            UserActivityFollowing(vm: vm)
                        case .newReview:
                            UserActivityReview(vm: vm, mediasViewModel: mediasViewModel)
                        case .newCheckin:
                            UserActivityCheckin(vm: vm)
                        default:
                            Text(item.activityType.rawValue)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
            })
            .scrollIndicators(.hidden)
            .refreshable {
                Task {
                    if !vm.isLoading {
                        await vm.getActivity(id)
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(optionalValue: $vm.error)) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            if let error = vm.error {
                Text(error)
            } else {
                Text("Something went wrong :(")
            }
        }
    }
}

#Preview {
    UserActivityView(id: "Test")
}
