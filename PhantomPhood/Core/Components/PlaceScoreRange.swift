//
//  PlaceScoreRange.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct PlaceScoreRange: View {
    let score: Double?
    let isLoading: Bool
    let maxValue: Double
    
    init(score: Double?, isLoading: Bool = false, maxValue: Double = 5) {
        self.score = score
        self.isLoading = isLoading
        self.maxValue = maxValue
    }
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                Rectangle()
                    .foregroundStyle(.tertiary)
                
                if let score = score {
                    Rectangle()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: isLoading ? 0 : geometry.size.width * (score / maxValue))
                        .animation(.easeInOut(duration: 1), value: score)
                }
            })
        }
        .frame(height: 8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        PlaceScoreRange(score: 3.5, isLoading: true)
        PlaceScoreRange(score: 4.5, isLoading: false)
    }
}
