//
//  Emoji.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/18/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct Emoji: View {
    let emoji: EmojiesManager.Emoji
    @Binding var isAnimating: Bool
    let size: CGFloat
    
    init(_ emoji: EmojiesManager.Emoji, isAnimating: Binding<Bool>, size: CGFloat = 20) {
        self.emoji = emoji
        self._isAnimating = isAnimating
        self.size = size
    }
    
    init(reaction: Reaction, isAnimating: Binding<Bool>, size: CGFloat = 20) {
        let theEmoji = EmojiesVM.shared.dict[reaction.reaction]
        if let theEmoji {
            self.emoji = theEmoji
        } else {
            self.emoji = .init(symbol: reaction.reaction, title: "", keywords: [], categories: [], isAnimated: false, unicode: "")
        }
        self._isAnimating = isAnimating
        self.size = size
    }
    
    var body: some View {
        Group {
            if emoji.isAnimated, let gifName = emoji.gifName {
                AnimatedImage(name: gifName, isAnimating: $isAnimating)
                    .resizable()
                    .scaledToFit()
            } else {
                Text(emoji.symbol)
            }
        }
        .frame(maxWidth: size, maxHeight: size)
    }
}

#Preview {
    Text("😍")
        .font(.emoji(size: 20))
}
