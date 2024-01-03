//
//  SelectReactionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct SelectReactionsView: View {
    @ObservedObject var vm: SelectReactionsVM
    @ObservedObject private var emojisVM = EmojisVM.shared
    
    @State var selectedTab: EmojisManager.EmojiCategory = .common
    @State var isAnimating = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    ForEach(EmojisManager.EmojiCategory.allCases.indices, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectedTab = EmojisManager.EmojiCategory.allCases[index]
                            }
                        } label: {
                            Image(systemName: EmojisManager.EmojiCategory.allCases[index].icon)
                                .font(.system(size: 20))
                                .padding(.all, 8)
                        }
                        .foregroundStyle(selectedTab == EmojisManager.EmojiCategory.allCases[index] ? Color.accentColor : Color.secondary)
                        
                        if index + 1 <= EmojisManager.EmojiCategory.allCases.count {
                            Divider()
                                .frame(maxHeight: 24)
                        }
                    }
                }
                .font(.custom(style: .subheadline))
                .fontWeight(.semibold)
                
                Divider()
            }
            
            TabView(selection: $selectedTab) {
                ForEach(EmojisManager.EmojiCategory.allCases, id: \.self) { category in
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 36, maximum: 42)),
                        ], spacing: 16, content: {
                            ForEach(emojisVM.getEmojis(category: category)) { emoji in
                                Button {
                                    vm.onSelect?(emoji)
                                    vm.isPresented = false
                                } label: {
                                    Emoji(emoji, isAnimating: $isAnimating, size: 72)
                                }
                            }
                        })
                        .padding()
                    }
                    .tag(category)
                }
            }
            .ignoresSafeArea()
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .padding(.top)
        .presentationDetents([.height(300), .large])
        .onAppear {
            if !isAnimating {
                isAnimating = true
            }
        }
        .onDisappear {
            if isAnimating {
                isAnimating = false
            }
        }
    }
}

#Preview {
    SelectReactionsView(vm: SelectReactionsVM())
}
