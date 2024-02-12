//
//  MediasView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import SwiftUI
import Kingfisher

struct MediasView: View {
    @StateObject var vm: MediasVM
    
    @State var offset: CGSize = .zero
    var scale: CGFloat {
        return abs(offset.height) < 100 ? 1 - abs(offset.height) / 1000 : 0.9
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
                                    KFImage.url(url)
                                        .placeholder {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(Color.themePrimary)
                                                .overlay {
                                                    ProgressView()
                                                }
                                        }
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
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
                .ignoresSafeArea()
            } else {
                Text("Empty")
            }
            
            Button {
                vm.show = false
            } label: {
                Label(
                    title: { Text("Drag Down to Dismiss") },
                    icon: { Image(systemName: "chevron.down") }
                )
                .padding(.top)
            }
            .foregroundStyle(.secondary)
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
    @ObservedObject var vm = MediasVM()
    return MediasView(vm: vm)
        .onAppear {
            vm.show(medias: [
                .init(id: "Test1", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/af9ddd441be2d1d48450e96aaaed0658.jpg", caption: nil, type: .image),
                .init(id: "Test2", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/2a667b01b413fd08fd00a60b2f5ba3e1.mp4", caption: nil, type: .video)
            ])
        }
}
