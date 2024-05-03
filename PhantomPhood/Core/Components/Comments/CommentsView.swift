//
//  CommentsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: CommentsVM
    
    init(for activityId: String) {
        self._vm = StateObject(wrappedValue: CommentsVM(activityId: activityId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.comments.isEmpty && vm.loadingSections.contains(.gettingComments) {
                List(RepeatItem.create(2)) { _ in
                    HStack(alignment: .top) {
                        VStack(spacing: -14) {
                            ProfileImage(nil, size: 44)
                            
                            LevelView(level: 20)
                                .frame(width: 20, height: 25)
                        }
                        .redacted(reason: .placeholder)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text("Name")
                                        .font(.custom(style: .caption))
                                        .fontWeight(.semibold)
                                        .fontWidth(.compressed)
                                        .foregroundStyle(.primary)
                                    
                                    Text("1h")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                                Text("comment.content")
                                    .font(.custom(style: .body))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Image(systemName: "heart")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.secondary)
                                    .scaleEffect(0.9)
                                
                                Text("\(1)")
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                }
                .scrollIndicators(.never)
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
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: -14) {
                                ProfileImage(comment.author.profileImage, size: 44)
                                
                                LevelView(level: comment.author.progress.level)
                                    .frame(width: 20, height: 25)
                            }
                            .onTapGesture {
                                dismiss()
                                AppData.shared.goToUser(comment.author.id)
                            }
                            
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 4) {
                                        Text(comment.author.name)
                                            .font(.custom(style: .caption))
                                            .fontWeight(.semibold)
                                            .fontWidth(.compressed)
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
                                
                                VStack(spacing: 4) {
                                    Image(systemName: comment.liked ? "heart.fill" : "heart")
                                        .font(.system(size: 16))
                                        .foregroundStyle(comment.liked ? Color.accentColor : Color.secondary)
                                        .scaleEffect(comment.liked ? 1.1 : 0.9)
                                        .animation(.bouncy, value: comment.liked)
                                    
                                    Text("\(comment.likes)")
                                        .font(.custom(style: .caption2))
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !vm.loadingSections.contains(.submittingLike(comment.id)) {
                                        Task {
                                            await vm.updateCommentLike(for: comment.id, action: comment.liked ? .remove : .add)
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2, perform: {
                            if !vm.loadingSections.contains(.submittingLike(comment.id)) {
                                Task {
                                    await vm.updateCommentLike(for: comment.id, action: comment.liked ? .remove : .add)
                                }
                            }
                        })
                        .onAppear {
                            if !vm.loadingSections.contains(.gettingComments) && vm.comments.count > 9 && (vm.comments.firstIndex(where: { cm in cm.id == comment.id }) ?? 0) + 4 >= vm.comments.count {
                                Task {
                                    await vm.getComments()
                                }
                            }
                        }
                        .swipeActions {
                            Button {
                                dismiss()
                                AppData.shared.goTo(AppRoute.report(item: .comment(comment.id)))
                            } label: {
                                Text("Report")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                    }
                    .scrollIndicators(.never)
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
                    .opacity(vm.loadingSections.contains(.submittingComment) ? 0.6 : 1)
                    .disabled(vm.loadingSections.contains(.submittingComment))
                    .padding(.all, 11)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .task {
            await vm.getComments()
        }
        .presentationDetents([.medium, .fraction(0.99)])
    }
}

#Preview {
    CommentsView(for: "")
}
