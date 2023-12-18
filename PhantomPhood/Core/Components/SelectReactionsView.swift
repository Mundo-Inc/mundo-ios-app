//
//  SelectReactionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct SelectReactionsView: View {
    @ObservedObject private var vm = SelectReactionsVM.shared
    @ObservedObject private var emojiesVM = EmojiesVM.shared
    
    @State var selectedTab: EmojiesManager.EmojiCategory = .common
    @State var isAnimating = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    ForEach(EmojiesManager.EmojiCategory.allCases.indices, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectedTab = EmojiesManager.EmojiCategory.allCases[index]
                            }
                        } label: {
                            Image(systemName: EmojiesManager.EmojiCategory.allCases[index].icon)
                                .font(.system(size: 20))
                                .padding(.all, 8)
                        }
                        .foregroundStyle(selectedTab == EmojiesManager.EmojiCategory.allCases[index] ? Color.accentColor : Color.secondary)
                        
                        if index + 1 <= EmojiesManager.EmojiCategory.allCases.count {
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
                ForEach(EmojiesManager.EmojiCategory.allCases, id: \.self) { category in
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 36, maximum: 42)),
                        ], spacing: 16, content: {
                            ForEach(emojiesVM.getEmojies(category: category)) { emoji in
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
    SelectReactionsView()
}
