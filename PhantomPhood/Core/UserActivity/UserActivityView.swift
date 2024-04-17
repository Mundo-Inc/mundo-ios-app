//
//  UserActivityView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import SwiftUI

struct UserActivityView: View {
    private let id: String
    
    @StateObject private var vm = UserActivityVM()
    @StateObject private var mediasViewModel = MediasVM()
    
    @Environment(\.dismiss) private var dismiss
    
    init(id: String) {
        self.id = id
        self._vm = StateObject(wrappedValue: UserActivityVM())
    }
    
    init(feedItem: FeedItem) {
        self.id = feedItem.id
        self._vm = StateObject(wrappedValue: UserActivityVM(feedItem: feedItem))
    }
    
    var body: some View {
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
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            Task {
                if !vm.isLoading {
                    await vm.getActivity(id, referesh: true)
                }
            }
        }
        .fullScreenCover(isPresented: $mediasViewModel.show, content: {
            MediasView(vm: mediasViewModel)
        })
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
        .task {
            await vm.getActivity(id)
        }
    }
}

#Preview {
    UserActivityView(id: "Test")
}
