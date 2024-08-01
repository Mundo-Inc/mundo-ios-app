//
//  ImageWrapper.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/29/24.
//

import SwiftUI

struct ImageWrapper: View {
    private let image: Image
    private let contentMode: SwiftUI.ContentMode
    
    init(_ image: Image, contentMode: SwiftUI.ContentMode = .fill) {
        self.image = image
        self.contentMode = contentMode
    }
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .allowsHitTesting(false)
            }
            .clipped()
    }
}

#Preview {
    ImageWrapper(Image(systemName: "home"))
}
