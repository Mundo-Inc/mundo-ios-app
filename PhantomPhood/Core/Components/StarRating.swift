//
//  StarRating.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct StarRating: View {
    let score: CGFloat
    let activeColor: Color
    let size: CGFloat
    
    init(score: CGFloat, activeColor: Color = Color.accentColor, size: CGFloat = 14) {
        self.score = max(min(abs(score), 5), 0)
        self.activeColor = activeColor
        self.size = size
    }
    
    var body: some View {
        starsView
            .overlay {
                GeometryReader(content: { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(activeColor)
                            .frame(width: (score / 5) * geometry.size.width)
                    }
                })
                .mask(starsView)
            }
    }
    
    private var starsView: some View {
        HStack(spacing: 0) {
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
        }
        .font(.system(size: self.size))
        .foregroundStyle(Color.gray)
    }
}

#Preview {
    StarRating(score: 4)
}
