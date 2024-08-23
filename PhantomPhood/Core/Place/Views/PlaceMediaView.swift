//
//  PlaceMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct PlaceMediaView: View {
    @ObservedObject private var placeVM: PlaceVM
    
    private let namespace: Namespace.ID
    
    init(placeVM: PlaceVM, namespace: Namespace.ID) {
        self._placeVM = ObservedObject(wrappedValue: placeVM)
        self.namespace = namespace
    }
    
    let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            if let mediaItems = placeVM.mediaItems {
                if mediaItems.isEmpty {
                    Text("No media")
                        .cfont(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                        .padding(.horizontal)
                } else {
                    ForEach(mediaItems) { media in
                        ZStack(alignment: .bottomLeading) {
                            if let expandedMedia = placeVM.expandedMedia, media.id == expandedMedia.id {
                                Rectangle()
                                    .foregroundStyle(Color.themeBorder)
                            } else {
                                if media.type == .image, let url = media.src {
                                    ImageLoader(url, contentMode: .fill) { _ in
                                        Image(systemName: "arrow.down.circle.dotted")
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                    .matchedGeometryEffect(id: media.id, in: namespace)
                                    .aspectRatio(2/3, contentMode: .fill)
                                } else if let thumbnail = media.thumbnail {
                                    ImageLoader(thumbnail, contentMode: .fill) { _ in
                                        Image(systemName: "arrow.down.circle.dotted")
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                    .matchedGeometryEffect(id: media.id, in: namespace)
                                    .aspectRatio(2/3, contentMode: .fill)
                                    .overlay {
                                        Image(systemName: "video")
                                            .font(.system(size: 50))
                                            .foregroundStyle(Color.secondary)
                                    }
                                } else {
                                    Rectangle()
                                        .aspectRatio(2/3, contentMode: .fill)
                                        .foregroundStyle(Color.themePrimary)
                                        .overlay {
                                            Image(systemName: "video")
                                                .font(.system(size: 50))
                                                .foregroundStyle(Color.secondary)
                                        }
                                }
                                
                                Group {
                                    if let user = media.user {
                                        HStack(spacing: 5) {
                                            ProfileImage(user.profileImage, size: 24, cornerRadius: 12)
                                            
                                            Text(user.name)
                                                .cfont(.caption2)
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    } else if media.source == .yelp {
                                        Image(.yelpLogo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 30)
                                    } else if media.source == .google {
                                        Image(.googleLogo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 30)
                                    }
                                }
                                .padding(.leading, 5)
                                .padding(.bottom, 5)
                            }
                        }
                        .padding(.all, 1)
                        .background(Color.themeBorder)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .onTapGesture {
                            withAnimation {
                                placeVM.expandedMedia = media
                            }
                        }
                        .task {
                            await placeVM.loadMoreMedia(currentItem: media)
                        }
                    }
                }
            } else {
                ForEach(RepeatItem.create(9)) { _ in
                    Rectangle()
                        .foregroundStyle(Color.themePrimary)
                        .padding(.all, 1)
                        .background(Color.themeBorder)
                        .aspectRatio(2 / 3, contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(.bottom, 40)
        .onChange(of: placeVM.place != nil) { placeAvailable in
            if placeAvailable {
                Task {
                    await placeVM.fetchMedia(.new)
                }
            }
        }
    }
}

#Preview {
    PlaceMediaView(placeVM: PlaceVM(data: Placeholder.placeDetails[0], action: nil), namespace: Namespace().wrappedValue)
}
