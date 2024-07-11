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
    
    @Namespace private var namespace
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Comments")
                .cfont(.headline)
                .fontWeight(.semibold)
                .padding(.top, 15)
                .padding(.bottom, 12)
            
            Divider()
            
            if vm.comments.isEmpty && vm.loadingSections.contains(.gettingComments) {
                List(RepeatItem.create(8)) { _ in
                    commentItemPlaceholder
                }
                .listStyle(.plain)
                .scrollIndicators(.never)
                .frame(maxHeight: .infinity)
            } else {
                if vm.comments.isEmpty {
                    VStack {
                        Text("No Comments yet")
                            .cfont(.title2)
                        
                        Text("Be the first")
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                } else {
                    List($vm.comments) { cm in
                        let comment = vm.getComment(cm.wrappedValue, cm.wrappedValue.depth)
                        
                        HStack(alignment: .top, spacing: 12) {
                            VStack {
                                VStack(spacing: -14) {
                                    ProfileImage(comment.author.profileImage, size: 44)
                                    
                                    LevelView(level: comment.author.progress.level)
                                        .frame(width: 20, height: 25)
                                }
                                .onTapGesture {
                                    dismiss()
                                    AppData.shared.goToUser(comment.author.id)
                                }
                                
                                HStack(spacing: 3) {
                                    if let depth = cm.wrappedValue.depth, !depth.isEmpty {
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundStyle(.secondary.opacity(0.2))
                                        
                                        ForEach(depth, id: \.self) { _ in
                                            Rectangle()
                                                .frame(width: 1)
                                                .foregroundStyle(.secondary.opacity(0.2))
                                        }
                                    } else if let replies = comment.replies, !replies.isEmpty {
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundStyle(.secondary.opacity(0.2))
                                    }
                                }
                                .frame(width: 44)
                                .overlay(alignment: .leading) {
                                    if let depth = cm.wrappedValue.depth, !depth.isEmpty {
                                        Image(systemName: "chevron.left")
                                            .foregroundStyle(.secondary)
                                            .onTapGesture {
                                                let _ = cm.wrappedValue.depth!.popLast()
                                            }
                                    }
                                }
                            }
                            
                            VStack {
                                CommentHeader(comment)
                                    .id(comment.id + "header")
                                    .matchedGeometryEffect(id: comment.id + "header", in: namespace)
                                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity.animation(.easeOut(duration: 0))))
                                
                                Text("Reply")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                    .cfont(.caption)
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        withAnimation {
                                            vm.replyTo = comment
                                        }
                                    }
                                
                                
                                if let replies = comment.replies, !replies.isEmpty {
                                    Color.clear
                                        .frame(height: 10)
                                    
                                    ForEach(replies, id: \.self) { replyId in
                                        if let reply = vm.repliesDict[replyId] {
                                            Reply(reply, root: cm)
                                                .padding(.leading, 10)
                                        }
                                    }
                                }
                                
                                if let repliesCount = comment.repliesCount, repliesCount > (comment.replies?.count ?? 0) {
                                    let moreReplies = repliesCount - (comment.replies?.count ?? 0)
                                    Text("View \(moreReplies) more \(moreReplies > 1 ? "replies" : "reply")")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.secondary)
                                        .cfont(.caption)
                                        .fontWeight(.semibold)
                                        .onTapGesture {
                                            Task {
                                                await vm.populateReplies(comment)
                                            }
                                            withAnimation {
                                                cm.wrappedValue.showReply(comment.id)
                                            }
                                        }
                                        .padding(.top)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .onAppear {
                            if vm.comments.count >= CommentsVM.commentsPageLimit && (vm.comments.firstIndex(where: { cm in cm.id == comment.id }) ?? 0) + 4 >= vm.comments.count {
                                Task {
                                    await vm.getComments(.new)
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
                    .listStyle(.plain)
                    .scrollIndicators(.never)
                    .frame(maxHeight: .infinity)
                }
            }
            
            Divider()
            
            if let replyTo = vm.replyTo {
                HStack {
                    ProfileImageBase(replyTo.author.profileImage, size: 28)
                    
                    Text("Replying to **\(replyTo.author.name)**")
                        .cfont(.caption)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            vm.replyTo = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            MentionTextField(text: $vm.commentContent, size: 38, placeholder: "Add a comment", trailingPadding: 37)
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
                    .frame(height: 38)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .task {
            await vm.getComments(.refresh)
        }
        .presentationDetents([.fraction(0.7), .fraction(0.99)])
    }
    
    func makeAttributedString(_ comment: Comment) -> AttributedString {
        let text = comment.content
        var attributedString = AttributedString(text)
        
        do {
            let mentionPattern = try NSRegularExpression(pattern: "(?:(?<=\\s)|^)@\\w+", options: [])
            let matches = mentionPattern.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let range = Range(match.range, in: text), let attributedRange = Range(match.range, in: attributedString),
                   let mentions = comment.mentions,
                   let user = mentions.first(where: { "@\($0.username.lowercased())".caseInsensitiveCompare(text[range]) == .orderedSame }),
                   let url = URL(string: "\(K.appURLScheme)://user/\(user.user)") {
                    attributedString[attributedRange].foregroundColor = .accentColor
                    attributedString[attributedRange].link = url
                }
            }
        } catch {
            print("Failed to create regular expression: \(error)")
        }
        
        return attributedString
    }
    
    @ViewBuilder
    private func CommentHeader(_ comment: Comment) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text(comment.author.name)
                        .cfont(.caption)
                        .fontWeight(.semibold)
                        .fontWidth(.compressed)
                        .foregroundStyle(.primary)
                    
                    Text(comment.createdAt.timeElapsed())
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Text(makeAttributedString(comment))
                    .cfont(.body)
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
                    .cfont(.caption2)
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
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            Task {
                await vm.updateCommentLike(for: comment.id, action: comment.liked ? .remove : .add)
            }
        })
    }
    
    @ViewBuilder
    private func Reply(_ comment: Comment, root: Binding<Comment>) -> some View {
        CommentHeader(comment)
            .id(comment.id + "header")
            .matchedGeometryEffect(id: comment.id + "header", in: namespace)
            .overlay(alignment: .topLeading) {
                ProfileImage(comment.author.profileImage, size: 28)
                    .offset(x: -34)
            }
            .transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity.animation(.easeOut(duration: 0.1))))
        
        HStack {
            Text("Reply")
                .onTapGesture {
                    withAnimation {
                        vm.replyTo = comment
                    }
                }
            
            if let repliesCount = comment.repliesCount, repliesCount > 0 {
                Divider()
                    .frame(height: 10)
                
                Text("See ^[\(repliesCount) reply](inflect: true)")
                    .onTapGesture {
                        Task {
                            await vm.populateReplies(comment)
                        }
                        withAnimation {
                            root.wrappedValue.showReply(comment.id)
                        }
                    }
            }
            
            Spacer()
        }
        .foregroundStyle(.secondary)
        .cfont(.caption)
        .fontWeight(.semibold)
    }
    
    private var commentItemPlaceholder: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                VStack(spacing: -14) {
                    ProfileImage(nil, size: 44)
                    
                    Color.clear
                        .frame(width: 20, height: 25)
                }
                
                HStack(spacing: 3) {
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(.secondary.opacity(0.2))
                }
                .frame(width: 44)
            }
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            Text("Name")
                                .cfont(.caption)
                                .fontWeight(.semibold)
                                .fontWidth(.compressed)
                                .foregroundStyle(.primary)
                            
                            Text("1d")
                                .cfont(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Comment body placeholder")
                            .cfont(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.secondary)
                            .scaleEffect(0.9)
                        
                        Text("1")
                            .cfont(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 10)
                }
                
                Text("Reply")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .cfont(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .redacted(reason: .placeholder)
        .listRowInsets(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
    }
}

#Preview {
    NavigationStack {
        Color.themeBG
            .sheet(isPresented: .constant(true), content: {
                CommentsView(for: "")
            })
    }
}
