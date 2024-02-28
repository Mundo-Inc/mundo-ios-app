//
//  AnimatedStarRating.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/5/24.
//

import SwiftUI

struct AnimatedStarRating: View {
    let score: CGFloat
    let activeColor: Color
    let show: Bool
    let size: CGFloat
    
    init(score: CGFloat, activeColor: Color = Color.accentColor, size: CGFloat = 14, show: Bool = true) {
        self.score = max(min(score, 5), 0)
        self.activeColor = activeColor
        self.size = size
        self.show = show
    }
    
    var body: some View {
        starsView
            .overlay {
                GeometryReader(content: { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(activeColor)
                            .frame(width: (show ? score / 5 : 0) * geometry.size.width)
                            .animation(.easeIn(duration: 1), value: show)
                    }
                })
                .mask(starsView)
            }
    }
    
    private var starsView: some View {
        HStack(spacing: 0) {
            Image(systemName: "star.fill")
                .rotationEffect(show ? .zero : .degrees(-72))
                .opacity(show ? 1 : 0)
                .animation(.bouncy(duration: 0.6), value: show)
            Image(systemName: "star.fill")
                .rotationEffect(show ? .zero : .degrees(-72))
                .opacity(show ? 1 : 0)
                .animation(.bouncy(duration: 0.6).delay(0.1), value: show)
            Image(systemName: "star.fill")
                .rotationEffect(show ? .zero : .degrees(-72))
                .opacity(show ? 1 : 0)
                .animation(.bouncy(duration: 0.6).delay(0.2), value: show)
            Image(systemName: "star.fill")
                .rotationEffect(show ? .zero : .degrees(-72))
                .opacity(show ? 1 : 0)
                .animation(.bouncy(duration: 0.6).delay(0.3), value: show)
            Image(systemName: "star.fill")
                .rotationEffect(show ? .zero : .degrees(-72))
                .opacity(show ? 1 : 0)
                .animation(.bouncy(duration: 0.6).delay(0.4), value: show)
        }
        .font(.system(size: self.size))
        .foregroundStyle(Color.gray)
    }
}

#Preview {
    AnimatedStarRating(score: 4)
}
