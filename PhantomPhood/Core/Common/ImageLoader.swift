//
//  ImageLoader.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/29/24.
//

import SwiftUI
import Kingfisher

struct ImageLoader<Placeholder>: View where Placeholder : View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let placeholder: (Progress) -> Placeholder
    
    init(
        _ url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        @ViewBuilder placeholder: @escaping (Progress) -> Placeholder = { _ in EmptyView() }
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    init(
        _ string: String,
        contentMode: SwiftUI.ContentMode = .fill,
        @ViewBuilder placeholder: @escaping (Progress) -> Placeholder = { _ in EmptyView() }
    ) {
        self.url = URL(string: string)
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay {
                KingFisherImageLoader(url: url, contentMode: contentMode, placeholder: placeholder)
                    .allowsHitTesting(false)
            }
            .clipped()
    }
}

fileprivate struct KingFisherImageLoader<Placeholder>: View where Placeholder : View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let placeholder: (Progress) -> Placeholder
    
    init(
        url: URL?,
        contentMode: SwiftUI.ContentMode,
        @ViewBuilder placeholder: @escaping (Progress) -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        KFImage(url)
            .placeholder(placeholder)
            .onFailureImage(.errorLoading)
            .fade(duration: 0.2)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

#Preview {
    ImageLoader("https://picsum.photos/id/20/200", contentMode: .fill)
}
