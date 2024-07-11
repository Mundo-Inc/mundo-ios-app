//
//  MessagesView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var inboxVM: InboxVM
    @ObservedObject private var conversationsManager = ConversationsManager.shared
    
    var body: some View {
        VStack {
            Text("Messaging is temporarily disabled")
            Text("We're working on improving user experience")
                .cfont(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
//    var body: some View {
//        List(conversationsManager.conversations) { conversation in
//            NavigationLink(value: AppRoute.conversation(sid: conversation.sid ?? "-", focusOnTextField: false)) {
//                HStack(alignment: .top) {
//                    if let userId = conversation.targetUserId {
//                        if let user = inboxVM.usersDict[userId] {
//                            ProfileImage(user.profileImage, size: 56)
//                        } else {
//                            ProfileImage(nil, size: 56)
//                        }
//                    } else {
//                        RoundedRectangle(cornerRadius: 10)
//                            .shadow(radius: 5)
//                            .foregroundStyle(Color.themePrimary)
//                            .frame(width: 56, height: 56)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.themeBorder, lineWidth: 3)
//                                
//                                HStack(spacing: 3) {
//                                    Image(systemName: "person.2.fill")
//                                    Text("\(conversation.participantsCount)")
//                                }
//                                .foregroundStyle(.secondary)
//                            }
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 0) {
//                        HStack {
//                            Text(conversation.name)
//                                .cfont(.headline)
//                                .fontWeight(.semibold)
//                                .foregroundStyle(.primary)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .lineLimit(1)
//                            
//                            Text(conversation.lastMessageDateFormatted)
//                                .cfont(.caption2)
//                                .foregroundStyle(.secondary)
//                        }
//                        
//                        Group {
//                            if let sid = conversation.sid, let typingSet = conversationsManager.typingParticipants[sid], !typingSet.isEmpty {
//                                Text("Typing...")
//                            } else if let authId = Authentication.shared.currentUser?.id, authId == conversation.lastMessageContentAuthor {
//                                Text("**You:** \(conversation.lastMessagePreview ?? "-")")
//                            } else {
//                                Text(conversation.lastMessagePreview ?? "")
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .lineLimit(1)
//                        .cfont(.caption)
//                        
//                        if !conversation.lastMessageContentIcon.isEmpty {
//                            Image(systemName: conversation.lastMessageContentIcon)
//                                .font(.system(size: 16))
//                        }
//                    }
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .padding(.leading)
//            }
//            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
//            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
//            .listRowBackground(conversation.unreadMessagesCount > 0 ? Color.accentColor.opacity(0.15) : Color.themeBG)
//            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                Button(role: .destructive) {
//                    Task {
//                        try await conversationsManager.leave(conversation: conversation)
//                    }
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                }
//            }
//        }
//        .listStyle(.plain)
//        .task {
//            let users = conversationsManager.conversations.compactMap { $0.targetUserId }
//            await inboxVM.getUsers(ids: users)
//        }
//        .onChange(of: conversationsManager.conversations) { conversations in
//            let users = conversations.compactMap { $0.targetUserId }
//            Task {
//                await inboxVM.getUsers(ids: users)
//            }
//        }
//        .overlay {
//            switch conversationsManager.clientState {
//            case .connecting:
//                ProgressView()
//            case .denied, .disconnected, .error, .fatalError:
//                VStack {
//                    Image(systemName: "exclamationmark.triangle")
//                        .font(.system(size: 20))
//                        .foregroundStyle(.secondary)
//                    
//                    Text("Failed to connect to messaging service")
//                        .cfont(.caption)
//                        .foregroundStyle(.secondary)
//                }
//            default:
//                EmptyView()
//            }
//        }
//    }
}

#Preview {
    MessagesView()
}
