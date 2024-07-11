//
//  SelectReactionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct SelectReactionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var emojisVM = EmojisVM.shared
    
    @State private var selectedTab: EmojisManager.EmojiCategory = .common
    @State private var isAnimating = true
    
    private let onSelect: (EmojisManager.Emoji) -> Void
    
    init(onSelect: @escaping (EmojisManager.Emoji) -> Void) {
        self.onSelect = onSelect
    }
    
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
                .cfont(.subheadline)
                .fontWeight(.semibold)
                
                Divider()
            }
            
            TabView(selection: $selectedTab) {
                ForEach(EmojisManager.EmojiCategory.allCases, id: \.self) { category in
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 40, maximum: 48)),
                        ], spacing: 16, content: {
                            ForEach(emojisVM.getEmojis(category: category)) { emoji in
                                Button {
                                    dismiss()
                                    onSelect(emoji)
                                } label: {
                                    Emoji(emoji, isAnimating: $isAnimating, size: 40)
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
        .presentationDetents([.height(300), .fraction(0.99)])
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
    SelectReactionsView { _ in }
}
