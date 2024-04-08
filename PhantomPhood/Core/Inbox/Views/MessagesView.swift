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
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(conversationsManager.conversations) { conversation in
                    if let authId = Authentication.shared.currentUser?.id, let userId = conversation.friendlyName?.split(separator: "_").map({ String($0) }).filter({ $0 != authId }).first {
                        HStack(alignment: .top) {
                            if let user = inboxVM.usersDict[userId] {
                                ProfileImage(user.profileImage, size: 56, cornerRadius: 28)
                            } else {
                                ProfileImage("", size: 56, cornerRadius: 28)
                                    .onAppear {
                                        Task {
                                            await inboxVM.getUser(id: userId)
                                        }
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(inboxVM.usersDict[userId]?.name ?? "-")
                                        .font(.custom(style: .headline))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    
                                    Text(conversation.lastMessageDateFormatted)
                                        .font(.custom(style: .caption2))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Group {
                                    if let sid = conversation.sid, let typingSet = conversationsManager.typingParticipants[sid], !typingSet.isEmpty {
                                        Text("Typing...")
                                    } else {
                                        if let authId = Authentication.shared.currentUser?.id, authId == conversation.lastMessageContentAuthor {
                                            Text("**You:** \(conversation.lastMessagePreview ?? "-")")
                                        } else {
                                            Text(conversation.lastMessagePreview ?? "-")
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                
                                if !conversation.lastMessageContentIcon.isEmpty {
                                    Image(systemName: conversation.lastMessageContentIcon)
                                        .font(.system(size: 16))
                                }
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .overlay(alignment: .leading) {
                            if conversation.unreadMessagesCount > 0 {
                                Rectangle()
                                    .frame(width: 3)
                                    .shadow(color: Color.accentColor, radius: 2)
                                    .foregroundStyle(Color.accentColor)
                                    .transition(AnyTransition.opacity.animation(.spring))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let sid = conversation.sid {
                                AppData.shared.goTo(.conversation(sid: sid, focusOnTextField: false))
                            }
                        }
                        
                        Divider()
                    }
                }
            }
        }
    }
}

fileprivate struct ConversationRowItem: View {
    @EnvironmentObject private var inboxVM: InboxVM
    let conversation: PersistentConversationDataItem
    
    var user: UserEssentials? {
        if let authId = Authentication.shared.currentUser?.id, let userId = conversation.friendlyName?.split(separator: "_").map({ String($0) }).filter({ $0 != authId }).first {
            if let found = inboxVM.usersDict[userId] {
                return found
            } else {
                Task {
                    await inboxVM.getUser(id: userId)
                }
            }
        }
        return nil
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ProfileImage(user?.profileImage, size: 56, cornerRadius: 28)
                .overlay(alignment: .topLeading) {
                    if conversation.unreadMessagesCount > 0 {
                        Circle()
                            .frame(width: 6, height: 6)
                            .shadow(color: Color.accentColor, radius: 2)
                            .foregroundStyle(Color.accentColor)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
                    }
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(user?.name ?? "-")
                    .font(.custom(style: .headline))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Group {
                    if let authId = Authentication.shared.currentUser?.id, authId == conversation.lastMessageContentAuthor {
                        Text("**You:** \(conversation.lastMessagePreview ?? "-")")
                    } else {
                        Text(conversation.lastMessagePreview ?? "-")
                    }
                }
                .lineLimit(1)
                
                if !conversation.lastMessageContentIcon.isEmpty {
                    Image(systemName: conversation.lastMessageContentIcon)
                        .font(.system(size: 16))
                        .background(Color.green)
                }
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(conversation.lastMessageDateFormatted)
                .font(.custom(style: .caption2))
                .foregroundStyle(.secondary)
        }
        .redacted(reason: user == nil ? .placeholder : [])
    }
}

#Preview {
    MessagesView()
}
