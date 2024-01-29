//
//  PlaceMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI
import Kingfisher

struct PlaceMediaView: View {
    @ObservedObject var vm: PlaceVM
    
    @StateObject var placeMediaViewModel: PlaceMediaViewModel
    
    init(placeId: String, vm: PlaceVM) {
        self.vm = vm
        self._placeMediaViewModel = StateObject(wrappedValue: PlaceMediaViewModel(placeId: placeId))
    }
    
    let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        ScrollView {
            if placeMediaViewModel.isLoading && placeMediaViewModel.medias.isEmpty {
                Group {
                    Rectangle()
                    Rectangle()
                    Rectangle()
                    Rectangle()
                }
                .aspectRatio(2 / 3, contentMode: .fill)
                .foregroundStyle(Color.themePrimary)
            } else if placeMediaViewModel.medias.isEmpty {
                Text("No media")
                    .font(.custom(style: .subheadline))
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 0) {
                    ForEach(placeMediaViewModel.medias) { media in
                        ZStack {
                            Group {
                                if media.type == .image, let url = URL(string: media.src) {
                                    KFImage.url(url)
                                        .placeholder {
                                            Rectangle()
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
                                        .aspectRatio(2 / 3, contentMode: .fill)
                                        .contentShape(Rectangle())
                                } else {
                                    Rectangle()
                                        .aspectRatio(2 / 3, contentMode: .fill)
                                        .foregroundStyle(Color.themePrimary)
                                        .overlay {
                                            Image(systemName: "video")
                                                .font(.system(size: 50))
                                                .foregroundStyle(Color.secondary)
                                        }
                                }
                            }
                            .overlay(alignment: .bottomLeading) {
                                if let user = media.user {
                                    HStack(spacing: 5) {
                                        ProfileImage(user.profileImage, size: 24, cornerRadius: 12)
                                        
                                        Text(user.name)
                                            .font(.custom(style: .caption2))
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 5)
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                        .padding(.all, 1)
                        .background(Color.themeBorder)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onAppear {
                            Task {
                                await placeMediaViewModel.fetch(type: .new)
                            }
                        }
                }
                .clipped()
            }
        }
    }
}

#Preview {
    PlaceMediaView(placeId: "645c1d1ab41f8e12a0d166bc", vm: PlaceVM(id: "645c1d1ab41f8e12a0d166bc"))
}
