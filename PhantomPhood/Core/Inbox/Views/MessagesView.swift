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
        List(conversationsManager.conversations) { conversation in
            if let authId = Authentication.shared.currentUser?.id, let userId = conversation.friendlyName?.split(separator: "_").map({ String($0) }).filter({ $0 != authId }).first {
                NavigationLink(value: AppRoute.conversation(sid: conversation.sid ?? "-", focusOnTextField: false)) {
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
                                Text(inboxVM.usersDict[userId]?.name ?? "Name")
                                    .font(.custom(style: .headline))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .redacted(reason: inboxVM.usersDict[userId] == nil ? .placeholder : [])
                                
                                Text(conversation.lastMessageDateFormatted)
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Group {
                                if let sid = conversation.sid, let typingSet = conversationsManager.typingParticipants[sid], !typingSet.isEmpty {
                                    Text("Typing...")
                                } else {
                                    if authId == conversation.lastMessageContentAuthor {
                                        Text("**You:** \(conversation.lastMessagePreview ?? "-")")
                                    } else {
                                        Text(conversation.lastMessagePreview ?? "")
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .font(.custom(style: .caption))
                            
                            if !conversation.lastMessageContentIcon.isEmpty {
                                Image(systemName: conversation.lastMessageContentIcon)
                                    .font(.system(size: 16))
                            }
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                .listRowBackground(conversation.unreadMessagesCount > 0 ? Color.accentColor.opacity(0.15) : Color.themeBG)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    MessagesView()
}
