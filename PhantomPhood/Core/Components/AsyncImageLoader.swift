//
//  AsyncImageLoader.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/27/23.
//

import SwiftUI

struct AsyncImageLoader<PlaceholderContent: View, ErrorContent: View>: View {
    private let url: URL
    private let placeholder: PlaceholderContent
    private let errorView: ErrorContent?
    @ObservedObject var binder = AsyncImageBinder()
    
    init(
        _ url: URL,
        @ViewBuilder placeholder: () -> PlaceholderContent = { ProgressView() },
        @ViewBuilder errorView: () -> ErrorContent = {
            Rectangle()
                .foregroundStyle(Color.themePrimary)
                .overlay {
                    Image(systemName: "exclamationmark.icloud")
                        .foregroundStyle(.red)
                }
        }
    ) {
        self.url = url
        self.placeholder = placeholder()
        self.errorView = errorView()
        
        self.binder.load(url: url)
    }
    
    var body: some View {
        VStack {
            switch binder.state {
            case .loading:
                placeholder
            case .ready:
                if let image = binder.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            case .error:
                errorView
            }
        }
    }
}

#Preview {
    AsyncImageLoader(
        URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64d29e412c509f60b768f240/images/3666139990c19d686988b14d23f68754.jpg")!
    )
    .frame(width: 300, height: 300)
    .clipShape(RoundedRectangle(cornerRadius: 15))
}
