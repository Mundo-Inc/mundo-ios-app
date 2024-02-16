//
//  CommentsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI

struct CommentsView: View {
    @ObservedObject private var vm = CommentsVM.shared
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    @Environment(\.dismiss) private var dismiss
    
    func navigateToUserProfile(userId: String) {
        if let currentUserId = auth.currentUser?.id, currentUserId == userId {
            appData.activeTab = .myProfile
            dismiss()
            return
        }
        switch appData.activeTab {
        case .home:
            appData.homeNavStack.append(.userProfile(userId: userId))
        case .explore:
            appData.exploreNavStack.append(.userProfile(userId: userId))
        case .rewardsHub:
            appData.rewardsHubNavStack.append(.userProfile(userId: userId))
        case .myProfile:
            appData.myProfileNavStack.append(.userProfile(userId: userId))
        }
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.comments.isEmpty && vm.isLoading {
                List(0..<1) { _ in
                    HStack(alignment: .top) {
                        VStack(spacing: -15) {
                            ProfileImage("", size: 44, cornerRadius: 10)
                            
                            LevelView(level: 20)
                                .frame(width: 24, height: 30)
                                .clipShape(.rect(cornerRadius: 5))
                        }
                        .redacted(reason: .placeholder)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(String(repeating: "A", count: 8))
                                        .font(.custom(style: .body))
                                        .bold()
                                        .foregroundStyle(.primary)
                                    Text("2h")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                                Text(String(repeating: "A", count: 22))
                                    .font(.custom(style: .body))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity)
                            .redacted(reason: .placeholder)
                            
                            VStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.secondary)
                                Text("10")
                                    .font(.custom(style: .callout))
                                    .foregroundStyle(.secondary)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                if vm.comments.isEmpty {
                    VStack {
                        Text("No Comments yet")
                            .font(.custom(style: .title2))
                        
                        Text("Be the first")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                } else {
                    List(vm.comments) { comment in
                        HStack(alignment: .top) {
                            VStack(spacing: -15) {
                                ProfileImage(comment.author.profileImage, size: 44, cornerRadius: 10)
                                
                                LevelView(level: comment.author.progress.level)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 30)
                            }
                            .onTapGesture(perform: {
                                navigateToUserProfile(userId: comment.author.id)
                            })
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(comment.author.name)
                                            .font(.custom(style: .body))
                                            .bold()
                                            .foregroundStyle(.primary)
                                        
                                        Text(comment.createdAt.timeElapsed())
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Text(comment.content)
                                        .font(.custom(style: .body))
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Image(systemName: comment.liked ? "heart.fill" : "heart")
                                        .font(.system(size: 16))
                                        .foregroundStyle(comment.liked ? Color.accentColor : Color.secondary)
                                    Text("\(comment.likes)")
                                        .font(.custom(style: .callout))
                                        .foregroundStyle(.secondary)
                                }
                                .animation(.easeInOut, value: vm.isSubmitting)
                                .opacity(vm.isSubmitting ? 0.6 : 1)
                                .onTapGesture(perform: {
                                    if !vm.isSubmitting {
                                        Task {
                                            await vm.updateCommentLike(id: comment.id, action: comment.liked ? .remove : .add)
                                        }
                                    }
                                })
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .onAppear {
                            if !vm.isLoading && vm.comments.count > 9 && (vm.comments.firstIndex(where: { cm in cm.id == comment.id }) ?? 0) + 4 >= vm.comments.count {
                                if let activityId = vm.currentActivityId {
                                    Task {
                                        await vm.getComments(activityId: activityId)
                                    }
                                }
                            }
                        }
                        .swipeActions {
                            Button {
                                dismiss()
                                appData.goTo(AppRoute.report(id: comment.id, type: .comment))
                            } label: {
                                Text("Report")
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            
            Divider()
            
            TextField("Add a comment", text: $vm.commentContent, axis: .vertical)
                .lineLimit(1...4)
                .padding(.all, 10)
                .padding(.trailing, 37)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themePrimary)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        Task {
                            await vm.submitComment()
                        }
                    } label: {
                        Text("Post")
                    }
                    .opacity(vm.isSubmitting ? 0.6 : 1)
                    .disabled(vm.isSubmitting)
                    .padding(.all, 11)
                }.padding(.horizontal)
                .padding(.vertical, 10)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    CommentsView()
}
