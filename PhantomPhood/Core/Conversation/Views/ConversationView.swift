//
//  ConversationView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import SwiftUI

struct ConversationView: View {
    @ObservedObject private var conversationsManager = ConversationsManager.shared
    
    @StateObject private var vm: ConversationVM
    
    let shouldFocusOnTextField: Bool
    init(_ sid: String, focusOnTextField: Bool = false) {
        self.shouldFocusOnTextField = focusOnTextField
        self._vm = StateObject(wrappedValue: ConversationVM(sid: sid))
    }
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    @State private var isAnimating = true
    
    @State private var scrollProxy: SwiftUI.ScrollViewProxy?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if !vm.messages.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.messages.indices, id: \.self) { index in
                                let message = vm.messages[index]
                                
                                if let createdAt = message.dateCreated {
                                    if index == 0 {
                                        Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .padding(.vertical, 5)
                                    } else {
                                        if let prevMessageCreatedAt = vm.messages[index - 1].dateCreated, !Calendar.current.isDate(prevMessageCreatedAt, inSameDayAs: createdAt) {
                                            Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                                                .font(.custom(style: .caption))
                                                .foregroundStyle(.secondary)
                                                .padding(.vertical, 5)
                                        }
                                    }
                                }
                                
                                HStack {
                                    if message.direction == MessageDirection.outgoing.rawValue {
                                        Spacer()
                                    }
                                    
                                    if let body = message.body {
                                        if body.isSingleEmoji {
                                            Emoji(symbol: body, isAnimating: $isAnimating, size: 46)
                                                .padding(.top, 8)
                                                .padding(.bottom, 22)
                                                .overlay(alignment: .bottomTrailing) {
                                                    if let createdAt = message.dateCreated {
                                                        Text(createdAt.formattedTime())
                                                            .font(.custom(style: .caption2))
                                                            .foregroundStyle(.secondary)
                                                            .padding(.bottom, 3)
                                                            .padding(.trailing, 8)
                                                    }
                                                }
                                        } else {
                                            VStack(alignment: .leading) {
                                                Text(body)
                                                    .frame(minWidth: 50, alignment: .leading)
                                            }
                                            .padding(.all, 8)
                                            .padding(.bottom, 14)
                                            .background(message.direction == MessageDirection.outgoing.rawValue ? Color.accentColor.opacity(0.7) : Color.themePrimary)
                                            .overlay(alignment: .bottomTrailing) {
                                                if let createdAt = message.dateCreated {
                                                    Text(createdAt.formattedTime())
                                                        .font(.custom(style: .caption2))
                                                        .foregroundStyle(.secondary)
                                                        .padding(.bottom, 3)
                                                        .padding(.trailing, 8)
                                                }
                                            }
                                            .clipShape(
                                                message.direction == MessageDirection.outgoing.rawValue ?
                                                    .rect(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 10) :
                                                        .rect(topLeadingRadius: 10, bottomLeadingRadius: 0, bottomTrailingRadius: 10, topTrailingRadius: 10)
                                            )
                                        }
                                    } else {
                                        Text("Unsupported message")
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    
                                    if message.direction == MessageDirection.incoming.rawValue {
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                                .padding(message.direction == MessageDirection.outgoing.rawValue ? .leading : .trailing, mainWindowSize.width * 0.1)
                                .id(message.messageIndex)
                                .transition(AnyTransition.opacity.animation(.easeIn))
                            }
                        }
                        .onAppear {
                            proxy.scrollTo("bottom")
                            self.scrollProxy = proxy
                        }
                        
                        if let typingSet = conversationsManager.typingParticipants[vm.conversationSid], !typingSet.isEmpty {
                            HStack {
                                TimelineView(.animation(minimumInterval: 0.5)) { timeline in
                                    let value = timeline.date.timeIntervalSince1970.rounded(toPlaces: 1) * 10
                                    
                                    HStack {
                                        Group {
                                            Circle()
                                                .scaleEffect(value.truncatingRemainder(dividingBy: 3) == 2 ? 1.4 : 1)
                                            Circle()
                                                .scaleEffect(value.truncatingRemainder(dividingBy: 3) == 1 ? 1.4 : 1)
                                            Circle()
                                                .scaleEffect(value.truncatingRemainder(dividingBy: 3) == 0 ? 1.4 : 1)
                                        }
                                        .frame(width: 6, height: 6)
                                        .foregroundStyle(.secondary)
                                        .animation(.bouncy, value: value)
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(height: 15)
                            .padding(.bottom, -25)
                            .padding(.leading)
                            .id("typingIndicator")
                            .transition(AnyTransition.asymmetric(insertion: .opacity.animation(.easeIn), removal: .identity.animation(.easeOut(duration: 0))))
                        }
                        
                        Color.clear
                            .frame(height: 25)
                            .id("bottom")
                    }
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: vm.messages.count) { value in
                        withAnimation {
                            proxy.scrollTo("bottom")
                        }
                        
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1) {
                            Task {
                                await vm.markAllMessagesAsRead()
                            }
                        }
                    }
                    .onChange(of: isFocused) { newValue in
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    proxy.scrollTo("bottom")
                                }
                            }
                        }
                    }
                }
            } else {
                ZStack {
                    LottieView(file: .wanderingGhost, loop: true)
                        .frame(width: mainWindowSize.width * 0.8)
                        .allowsHitTesting(false)
                    
                    VStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 20).onChanged({ value in
                                if isFocused {
                                    isFocused = false
                                }
                            }))
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "❤️") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Emoji(symbol: "❤️", isAnimating: $isAnimating, size: 20)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 14)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "🍾") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Emoji(symbol: "🍾", isAnimating: $isAnimating, size: 20)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 14)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "👻") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Emoji(symbol: "👻", isAnimating: $isAnimating, size: 20)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 14)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "Hola!") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Hola!")
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 12)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "Batman?") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Batman?")
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 12)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Button {
                                    Task {
                                        await vm.sendMessage(text: "Mommy?") { error in
                                            if let scrollProxy {
                                                withAnimation {
                                                    scrollProxy.scrollTo("bottom")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Mommy?")
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 12)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.never)
                        .padding(.bottom, 8)
                        .foregroundStyle(.primary.opacity(0.9))
                    }
                }
            }
            
            TextField("Message", text: $vm.messageText, axis: .vertical)
                .lineLimit(1...5)
                .focused($isFocused)
                .padding(.all, 10)
                .padding(.trailing, 37)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themeBG.opacity(0.7))
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        Task {
                            await vm.sendMessage() { error in
                                if let scrollProxy {
                                    withAnimation {
                                        scrollProxy.scrollTo("bottom")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Send")
                    }
                    .opacity(vm.loadingSections.contains(.sendingMessage) ? 0.6 : 1)
                    .disabled(vm.messageText.isEmpty || vm.loadingSections.contains(.sendingMessage))
                    .padding(.all, 11)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.themePrimary)
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavigationLink(value: AppRoute.userProfile(userId: vm.user?.id ?? "-")) {
                    VStack {
                        Text(vm.user?.name ?? "Name")
                            .font(.custom(style: .subheadline))
                        
                        Text("@\(vm.user?.username ?? "username")")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    .redacted(reason: vm.user == nil ? .placeholder : [])
                }
                .foregroundStyle(.primary)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.userProfile(userId: vm.user?.id ?? "-")) {
                    ProfileImage(vm.user?.profileImage, size: 36)
                }
            }
        }
        .onDisappear {
            isAnimating = false
        }
        .onAppear {
            if self.shouldFocusOnTextField {
                isFocused = true
            }
            
            isAnimating = true
        }
        .task {
            await vm.loadLastMessages()
        }
        .task {
            await vm.markAllMessagesAsRead()
        }
    }
}

#Preview {
    ConversationView("")
}
