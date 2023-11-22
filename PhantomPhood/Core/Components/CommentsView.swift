//
//  CommentsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI
import Kingfisher

struct CommentsView: View {
    @ObservedObject var vm: CommentsViewModel
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    @Environment(\.dismiss) var dismiss
    
    func navigateToUserProfile(id: String) {
        if let userId = auth.currentUser?.id, userId == id {
            appData.activeTab = .myProfile
            dismiss()
            return
        }
        switch appData.activeTab {
        case .home:
            appData.homeNavStack.append(.userProfile(id: id))
        case .map:
            appData.mapNavStack.append(.userProfile(id: id))
        case .leaderboard:
            appData.leaderboardNavStack.append(.userProfile(id: id))
        case .myProfile:
            appData.myProfileNavStack.append(.userProfile(id: id))
        }
        dismiss()
    }
    
    @State var reportId: String? = nil
            
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 30, height: 3)
                .foregroundStyle(.tertiary)
            Text("Comments")
                .font(.custom(style: .subheadline))
                .fontWeight(.bold)
                .padding(.top, 5)
            Divider()

            if vm.comments.isEmpty && vm.isLoading {
                ProgressView()
            } else {
                if vm.comments.isEmpty {
                    VStack {
                        Text("No Comments yet")
                            .font(.title2)

                        Text("Start the conversation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                } else {
                    List(vm.comments) { comment in
                        VStack {
                            HStack {
                                Group {
                                    if !comment.author.profileImage.isEmpty, let url = URL(string: comment.author.profileImage) {
                                        KFImage.url(url)
                                            .placeholder {
                                                Circle()
                                                    .frame(width: 44, height: 44)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            }
                                            .loadDiskFileSynchronously()
                                            .cacheMemoryOnly()
                                            .fade(duration: 0.25)
                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())
                                            .overlay(alignment: .top) {
                                                LevelView(level: comment.author.progress.level)
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 24, height: 30)
                                                    .offset(y: 28)
                                            }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .overlay(alignment: .top) {
                                                LevelView(level: comment.author.progress.level)
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 24, height: 30)
                                                    .offset(y: 28)
                                            }
                                    }
                                }
                                .onTapGesture(perform: {
                                    navigateToUserProfile(id: comment.author.id)
                                })
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(comment.author.name)
                                                .font(.custom(style: .body))
                                                .bold()
                                                .foregroundStyle(.primary)
                                            Text(DateFormatter.getPassedTime(from: comment.createdAt))
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
                                reportId = comment.id
                            } label: {
                                Text("Report")
                            }

                        }
                    }
                    .listStyle(.plain)
                }
            }
                        
            Spacer()
            
            Divider()
            
            TextField("Add a comment", text: $vm.commentContent, axis: .vertical)
                .lineLimit(1...4)
                .padding(.all, 8)
                .padding(.trailing, 35)
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
                    .padding(.all, 9)
                }.padding(.horizontal)
                .padding(.vertical, 5)

            
        }
        .padding(.top)
        .sheet(isPresented: Binding(optionalValue: $reportId)) {
            ReportView(id: $reportId, type: .comment)
        }
    }
}

#Preview {
    CommentsView(vm: CommentsViewModel())
}
