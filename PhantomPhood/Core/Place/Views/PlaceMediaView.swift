//
//  PlaceMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI
import Kingfisher

struct PlaceMediaView: View {
    @StateObject private var vm: PlaceMediaVM
    @ObservedObject private var placeVM: PlaceVM
    
    private let namespace: Namespace.ID
    
    init(placeVM: PlaceVM, namespace: Namespace.ID) {
        self._placeVM = ObservedObject(wrappedValue: placeVM)
        self._vm = StateObject(wrappedValue: PlaceMediaVM(placeVM: placeVM))
        self.namespace = namespace
    }
    
    let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        if let medias = vm.medias {
            if medias.isEmpty {
                Text("No media")
                    .font(.custom(style: .subheadline))
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 0) {
                    ForEach(medias) { media in
                        ZStack {
                            if let expandedMedia = placeVM.expandedMedia, case .phantom(let m) = expandedMedia, media.id == m.id {
                                Rectangle()
                                    .foregroundStyle(Color.themeBorder)
                            } else {
                                Group {
                                    if media.type == .image, let url = media.src {
                                        KFImage.url(url)
                                            .placeholder {
                                                Rectangle()
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            }
                                            .loadDiskFileSynchronously()
                                            .fade(duration: 0.25)
                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                            .resizable()
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .matchedGeometryEffect(id: media.id, in: namespace)
                                    } else if let thumbnail = media.thumbnail {
                                        KFImage.url(thumbnail)
                                            .placeholder {
                                                Rectangle()
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            }
                                            .loadDiskFileSynchronously()
                                            .fade(duration: 0.25)
                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                            .resizable()
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .matchedGeometryEffect(id: media.id, in: namespace)
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
                                .zIndex(2)
                            }
                        }
                        .padding(.all, 1)
                        .background(Color.themeBorder)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .onTapGesture {
                            withAnimation {
                                placeVM.expandedMedia = .phantom(media)
                            }
                        }
                    }
                    
                    if let yelpImages = placeVM.place?.thirdParty.yelp?.photos, !yelpImages.isEmpty {
                        ForEach(yelpImages, id: \.self) { string in
                            ZStack {
                                
                                if let expandedMedia = placeVM.expandedMedia, case .yelp(let s) = expandedMedia, string == s {
                                    Rectangle()
                                        .foregroundStyle(Color.themeBorder)
                                } else if let url = URL(string: string) {
                                    KFImage.url(url)
                                        .placeholder {
                                            Rectangle()
                                                .foregroundStyle(Color.themePrimary)
                                                .overlay {
                                                    ProgressView()
                                                }
                                        }
                                        .loadDiskFileSynchronously()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fill)
                                        .matchedGeometryEffect(id: string.hash, in: namespace)
                                        .overlay(alignment: .bottomTrailing) {
                                            Image(.yelpLogo)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxHeight: 30)
                                                .padding(.leading, 5)
                                                .padding(.bottom, 5)
                                        }
                                        .zIndex(2)
                                }
                            }
                            .padding(.all, 1)
                            .background(Color.themeBorder)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .onTapGesture {
                                withAnimation {
                                    placeVM.expandedMedia = .yelp(string)
                                }
                            }
                        }
                    }
                    
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onAppear {
                            Task {
                                await vm.fetch(type: .new)
                            }
                        }
                }
                .padding(.bottom, 40)
            }
        } else {
            LazyVGrid(columns: gridColumns, spacing: 0) {
                Group {
                    ZStack {
                        if placeVM.place != nil {
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                                .onAppear {
                                    Task {
                                        await vm.fetch(type: .refresh)
                                    }
                                }
                        } else {
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                        }
                    }
                    ForEach(0..<5, id: \.self) { item in
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                        }
                    }
                }
                .padding(.all, 1)
                .background(Color.themeBorder)
                .aspectRatio(2 / 3, contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    PlaceMediaView(placeVM: PlaceVM(id: "645c1d1ab41f8e12a0d166bc"), namespace: Namespace().wrappedValue)
}
