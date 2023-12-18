//
//  Emoji.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/18/23.
//

import SwiftUI

struct Emoji: View {
    let emoji: String
    let size: CGFloat
    
    init(_ emoji: String, size: CGFloat = 20) {
        self.emoji = emoji
        self.size = size
    }
    
    var body: some View {
        Text(emoji)
            .font(.custom("Noto Color Emoji", size: size))
    }
}

#Preview {
    Text("😍")
        .font(.emoji(size: 20))
}
