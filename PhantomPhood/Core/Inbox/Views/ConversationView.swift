//
//  ConversationView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/5/24.
//

import SwiftUI
import Lottie

struct ConversationView: View {
    @StateObject private var vm: ConversationVM
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @State private var playbackMode: LottiePlaybackMode = .paused
    
    init(id: String) {
        self._vm = StateObject(wrappedValue: ConversationVM(id: id))
    }
    
    init(user: IdOrData<UserEssentials>) {
        self._vm = StateObject(wrappedValue: ConversationVM(user: user))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.conversation != nil {
                ScrollViewReader { proxy in
                    ScrollView {
                        Divider()
                            .frame(minHeight: 10)
                            .opacity(0)
                        
                        LazyVStack(spacing: 10) {
                            ForEach(vm.messages) { message in
                                MessageItem(message)
                                    .task {
                                        vm.setReadIndex(index: message.index)
                                    }
                            }
                        }
                        
                        Divider()
                            .frame(minHeight: 0)
                            .opacity(0)
                            .id("Last")
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: vm.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo("Last")
                        }
                    }
                    .onAppear {
                        proxy.scrollTo("Last")
                    }
                }
            } else if let exists = vm.exists, !exists {
                VStack {
                    Text("No messages here yet...")
                        .cfont(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    LottieView(animation: .named("WanderingGhost"))
                        .playbackMode(playbackMode)
                        .frame(maxWidth: mainWindowSize.width, maxHeight: mainWindowSize.width)
                        .onAppear {
                            playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
                        }
                        .onDisappear {
                            playbackMode = .paused
                        }
                }
                .frame(maxHeight: .infinity)
            }
            
            TextField("Message", text: $vm.content, axis: .vertical)
                .lineLimit(1...5)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 19))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 38)
                .overlay(alignment: .bottomTrailing) {
                    let isDisabled = vm.content.isEmpty
                    Button {
                        vm.handleSend()
                    } label: {
                        Circle()
                            .frame(width: 32)
                            .foregroundStyle(Color.accentColor)
                            .overlay {
                                if #available(iOS 17.0, *) {
                                    Image(systemName: isDisabled ? "ellipsis" : "arrow.up")
                                        .contentTransition(.symbolEffect(.replace))
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.white)
                                } else {
                                    Image(systemName: isDisabled ? "ellipsis" : "arrow.up")
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.white)
                                }
                            }
                    }
                    .disabled(isDisabled)
                    .padding(.trailing, 3)
                    .padding(.bottom, 3)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
        }
        .toolbar {
            if let recepient = vm.recepient {
                if case .direct(let participant) = recepient {
                    ToolbarItem(placement: .principal) {
                        NavigationLink(value: AppRoute.userProfile(userId: participant.user.id)) {
                            Text(participant.user.name)
                                .cfont(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(Color.primary)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: AppRoute.userProfile(userId: participant.user.id)) {
                            ProfileImage(participant.user.profileImage, size: 36)
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .principal) {
                    Text("User Name")
                        .cfont(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .redacted(reason: .placeholder)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Circle()
                        .frame(width: 36)
                        .foregroundStyle(Color.themeBorder)
                }
            }
        }
    }
    
    @ViewBuilder
    private func MessageItem(_ message: ConversationMessageEssentials) -> some View {
        HStack {
            let userIsSender = message.sender.id == Authentication.shared.currentUser?.id
            if userIsSender {
                Spacer()
                    .frame(minWidth: mainWindowSize.width * 0.2)
            }
            
            
            VStack(alignment: .leading, spacing: 0) {
                if let content = message.content {
                    Text(content)
                        .padding(.bottom)
                }
            }
            .frame(minWidth: 80, alignment: .leading)
            .overlay(alignment: .bottomTrailing, content: {
                Text(message.createdAt.formattedTime())
                    .cfont(.caption)
                    .foregroundStyle(userIsSender ? Color.white.opacity(0.8) : Color.secondary.opacity(0.9))
                    .fixedSize(horizontal: true, vertical: false)
            })
            .padding(.all, 6)
            .padding(.horizontal, 4)
            .background(
                userIsSender ? Color.accentColor : Color.themePrimary,
                in: userIsSender
                ? .rect(topLeadingRadius: 15, bottomLeadingRadius: 15, bottomTrailingRadius: 2, topTrailingRadius: 8)
                : .rect(topLeadingRadius: 8, bottomLeadingRadius: 2, bottomTrailingRadius: 15, topTrailingRadius: 15)
            )
            .foregroundStyle(userIsSender ? Color.white : Color.primary)
            
            if !userIsSender {
                Spacer()
                    .frame(minWidth: mainWindowSize.width * 0.2)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ConversationView(user: .data(Placeholder.users[2]))
    }
}
