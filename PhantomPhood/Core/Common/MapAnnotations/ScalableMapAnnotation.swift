//
//  ScalableMapAnnotation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/12/24.
//

import SwiftUI

struct ScalableMapAnnotation: View {
    private let count: Int?
    private let scale: CGFloat
    private let image: Image
    
    init(scale: CGFloat, count: Int? = nil, image: Image? = nil) {
        self.count = count
        self.scale = scale
        self.image = image ?? Image(systemName: "mappin")
    }
    
    private var scaleValue: CGFloat {
        if let count {
            return max(scale + (CGFloat(min(count, 10)) / 5.0) * 0.4 - 0.2, 0.5)
        } else {
            return scale
        }
    }
    
    var body: some View {
        Circle()
            .foregroundStyle(Color.accentColor)
            .frame(width: 30, height: 30)
            .overlay {
                Circle()
                    .stroke(Color.themePrimary)
                
                if let count, count > 1 {
                    Text(count > 99 ? "99+" : "\(count)")
                        .cfont(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                } else if scale > 0.5 {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: 21, height: 21)
                }
            }
            .scaleEffect(scaleValue)
            .animation(.spring, value: scale)
    }
}
