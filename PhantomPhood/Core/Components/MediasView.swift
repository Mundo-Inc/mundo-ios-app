//
//  MediasView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import SwiftUI

struct MediasView: View {
    @StateObject var vm: MediasViewModel
    
    @State var offset: CGSize = .zero
    var scale: CGFloat {
        return abs(offset.height) < 100 ? 1 - abs(offset.height) / 1000 : 0.9
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    vm.show = false
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding()
            
            Spacer()
            
            if !vm.medias.isEmpty {
                VStack {
                    TabView {
                        ForEach(vm.medias) { media in
                            if media.type == .video {
                                ReviewVideoView(url: media.src)
                                    .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else if media.type == .image {
                                if let url = URL(string: media.src) {
                                    CacheAsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(Color.themePrimary)
                                                .overlay {
                                                    ProgressView()
                                                }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        default:
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(Color.themePrimary)
                                                .overlay {
                                                    Image(systemName: "exclamationmark.icloud")
                                                        .foregroundStyle(.red)
                                                }
                                        }
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                    .contentShape(RoundedRectangle(cornerRadius: 15))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                }
                .scaleEffect(scale)
                .offset(y: offset.height)
                .frame(maxHeight: .infinity)
            }            
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    offset = value.translation
                })
                .onEnded({ value in
                    if abs(value.translation.height) >= 100 {
                        vm.show = false
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                })
        )
        
    }
}

#Preview {
    MediasView(vm: MediasViewModel())
}
