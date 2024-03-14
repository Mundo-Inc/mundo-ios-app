//
//  Emoji.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/18/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct Emoji: View {
    let emoji: EmojisManager.Emoji
    @Binding var isAnimating: Bool
    let size: CGFloat
    
    init(_ emoji: EmojisManager.Emoji, isAnimating: Binding<Bool>, size: CGFloat = 20) {
        self.emoji = emoji
        self._isAnimating = isAnimating
        self.size = size
    }
    
    init(reaction: Reaction, isAnimating: Binding<Bool>, size: CGFloat = 20) {
        let theEmoji = EmojisVM.shared.dict[reaction.reaction]
        if let theEmoji {
            self.emoji = theEmoji
        } else {
            self.emoji = .init(symbol: reaction.reaction, title: "", keywords: [], categories: [], isAnimated: false, unicode: "")
        }
        self._isAnimating = isAnimating
        self.size = size
    }
    
    init(symbol: String, isAnimating: Binding<Bool>, size: CGFloat = 20) {
        let theEmoji = EmojisVM.shared.getEmoji(forSymbol: symbol)
        if let theEmoji {
            self.emoji = theEmoji
        } else {
            self.emoji = .init(symbol: symbol, title: "", keywords: [], categories: [], isAnimated: false, unicode: "")
        }
        self._isAnimating = isAnimating
        self.size = size
    }
    
    var body: some View {
        Group {
            if emoji.isAnimated, let gifName = emoji.gifName, isAnimating {
                AnimatedImage(name: gifName, isAnimating: $isAnimating)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if !emoji.unicode.isEmpty && UIImage(named: "Emojis/\(emoji.unicode)") != nil {
                Image("Emojis/\(emoji.unicode)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text(emoji.symbol)
                    .font(.system(size: size * 0.75))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    Emoji(.init(symbol: "❤️", title: "Heart", keywords: [], categories: [], isAnimated: true, unicode: "2764_fe0f"), isAnimating: .constant(true))
}
