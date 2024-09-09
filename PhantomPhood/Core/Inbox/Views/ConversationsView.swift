//
//  ConversationsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/2/24.
//

import SwiftUI

struct ConversationsView: View {
    @ObservedObject private var conversationManager = ConversationManager.shared
    
    var body: some View {
        List(conversationManager.conversations) { conversation in
            ConversationItem(conversation: conversation)
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            do {
                                try await conversation.delete()
                            } catch {
                                presentErrorToast(error)
                            }
                        }
                    } label: {
                        Text("Delete")
                    }
                }
        }
        .listStyle(.plain)
        .refreshable {
            await conversationManager.getConversations()
        }
    }
}

private struct ConversationItem: View {
    let conversation: Conversation
    
    var body: some View {
        if let currentUser = Authentication.shared.currentUser,
           let user = conversation.participants.first(where: { $0.user.id != currentUser.id }) {
            HStack(alignment: .top, spacing: 12) {
                ProfileImageBase(user.user.profileImage, size: 58)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(user.user.name)
                        .cfont(.headline)
                        .fontWeight(.semibold)
                    
                    if let lastMessage = conversation.getLastMessage() {
                        Text("\(lastMessage.sender.id == currentUser.id ? Text("You: ").bold() : Text(""))\(lastMessage.content ?? "-")")
                            .cfont(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text(conversation.createdAt.timeElapsed(format: .compact))
                        .foregroundStyle(Color.secondary)
                    
                    if let unread = conversation.getUnread(for: currentUser.id), unread > 0 {
                        Text(unread > 99 ? "+99" : String(unread))
                            .padding(.horizontal, 5)
                            .frame(height: 20)
                            .frame(minWidth: 20)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.white)
                    }
                }
                .cfont(.caption)
            }
            .frame(height: 58)
            .contentShape(Rectangle())
            .onTapGesture {
                AppData.shared.goTo(.conversation(.id(conversation.id)))
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ConversationsView()
}
