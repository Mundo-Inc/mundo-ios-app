//
//  LoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/2/24.
//

import SwiftUI

struct LoadingView: View {
    let size: CGFloat
    
    init(size: CGFloat = 24) {
        self.size = size
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1)) { timeline in
            let seconds = timeline.date.timeIntervalSince1970.rounded(toPlaces: 0)
            ZStack {
                RoundedRectangle(cornerRadius: size / 4)
                    .foregroundStyle(Color.primary)
                    .scaleEffect(seconds.truncatingRemainder(dividingBy: 2) == 0 ? 0.5 : 1.15)
                    .animation(.bouncy, value: seconds)
                
                RoundedRectangle(cornerRadius: size / 4.3)
                    .foregroundStyle(Color.accentColor)
                    .rotationEffect(.degrees(seconds.truncatingRemainder(dividingBy: 4) * 90))
                    .animation(.bouncy, value: seconds)
                
                RoundedRectangle(cornerRadius: size / 5.5)
                    .foregroundStyle(Color.primary)
                    .scaleEffect(seconds.truncatingRemainder(dividingBy: 4) == 0 ? 1 : 0.4)
                    .rotationEffect(.degrees(seconds.truncatingRemainder(dividingBy: 4) * 90))
                    .animation(.bouncy, value: seconds)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
        
        LoadingView(size: 50)
    }
}
