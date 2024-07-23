//
//  MediaItemsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import SwiftUI

struct MediaItemsView: View {
    @StateObject var vm: MediaItemsVM
    
    @State var offset: CGSize = .zero
    var scale: CGFloat {
        return abs(offset.height) < 100 ? 1 - abs(offset.height) / 1000 : 0.9
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if !vm.items.isEmpty {
                VStack {
                    TabView {
                        ForEach(vm.items) { media in
                            if media.type == .video {
                                ReviewVideoView(url: media.src)
                                    .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else if media.type == .image, let url = media.src {
                                ImageLoader(url, contentMode: .fill) { progress in
                                    Rectangle()
                                        .foregroundStyle(.clear)
                                        .frame(maxWidth: 150)
                                        .overlay {
                                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                .progressViewStyle(LinearProgressViewStyle())
                                        }
                                }
                                .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
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
    @ObservedObject var vm = MediaItemsVM()
    return MediaItemsView(vm: vm)
        .onAppear {
            vm.show([
                .init(id: "Test1", src: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/af9ddd441be2d1d48450e96aaaed0658.jpg"), caption: nil, type: .image),
                .init(id: "Test2", src: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/2a667b01b413fd08fd00a60b2f5ba3e1.mp4"), caption: nil, type: .video)
            ])
        }
}
