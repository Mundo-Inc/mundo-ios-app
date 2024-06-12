//
//  SimpleMapAnnotation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/12/24.
//

import SwiftUI

struct SimpleMapAnnotation: View {
    private let count: Int?
    private let image: Image
    
    init(count: Int? = nil, image: Image? = nil) {
        self.count = count
        self.image = image ?? Image(systemName: "mappin")
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
                        .font(.custom(style: .caption))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                } else {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                }
            }
    }
}

#Preview {
    SimpleMapAnnotation()
}
