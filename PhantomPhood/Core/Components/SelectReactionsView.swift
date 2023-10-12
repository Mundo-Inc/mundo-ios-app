//
//  SelectReactionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct NewReaction: Identifiable {
    let reaction: String
    let type: ReactionType
    var id: String {
        reaction + type.rawValue
    }
}

private let emojiList: [NewReaction] = [
    NewReaction(reaction: "👍", type: .emoji),
    NewReaction(reaction: "❤️", type: .emoji),
    NewReaction(reaction: "🥰", type: .emoji),
    NewReaction(reaction: "🤩", type: .emoji),
    NewReaction(reaction: "🎉", type: .emoji),
    NewReaction(reaction: "🤮", type: .emoji),
    NewReaction(reaction: "👎", type: .emoji),
    NewReaction(reaction: "🔥", type: .emoji),
    NewReaction(reaction: "😃", type: .emoji),
    NewReaction(reaction: "🤑", type: .emoji),
    NewReaction(reaction: "🤌", type: .emoji),
    NewReaction(reaction: "🍻", type: .emoji),
    NewReaction(reaction: "😑", type: .emoji),
    NewReaction(reaction: "😕", type: .emoji)
]

struct SelectReactionsView: View {
    @StateObject var vm = SelectReactionsViewModel.shared
    
    enum Tab {
        case emoji
        case special
    }
    
    @State var selectedTab: Tab = .emoji
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        selectedTab = .emoji
                    }
                } label: {
                    Text("Emoji")
                        .foregroundStyle(selectedTab == .emoji ? Color.accentColor : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(maxHeight: 20)
                
                Button {
                    withAnimation {
                        selectedTab = .special
                    }
                } label: {
                    Text("Special")
                        .foregroundStyle(selectedTab == .special ? Color.accentColor : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.custom(style: .subheadline))
            .fontWeight(.semibold)
            .padding(.top)
            
            Divider()
            
            TabView(selection: $selectedTab) {
                ScrollView {
                    WrappingHStack(horizontalSpacing: 30, verticalSpacing: 30) {
                        ForEach(emojiList) { emoji in
                            Button {
                                vm.onSelect?(emoji)
                                vm.isPresented = false
                            } label: {
                                Text(emoji.reaction)
                            }
                        }
                    }
                    .padding()
                }
                .tag(Tab.emoji)
                
                ScrollView {
                    Text("No Special reactions available")
                        .font(.custom(style: .subheadline))
                        .padding()
                }
                .onTapGesture {
                    withAnimation {
                        selectedTab = .emoji
                    }
                }
                .tag(Tab.special)
                    
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .padding(.top)
        .presentationDetents([.height(250), .large])
    }
}

#Preview {
    SelectReactionsView()
}
