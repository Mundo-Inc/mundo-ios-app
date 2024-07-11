//
//  PlaceMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

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
        LazyVGrid(columns: gridColumns, spacing: 0) {
            if !vm.initialCall {
                Group {
                    if placeVM.place != nil {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                                .task {
                                    await vm.fetch(type: .refresh)
                                }
                        }
                    } else {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                        }
                    }
                    ForEach(RepeatItem.create(5)) { _ in
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
            } else if let place = placeVM.place {
                if vm.medias.isEmpty {
                    Text("No media")
                        .cfont(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                        .padding(.horizontal)
                } else {
                    if let yelpImages = place.thirdParty.yelp?.photos {
                        ForEach(yelpImages, id: \.self) { string in
                            ZStack {
                                if let expandedMedia = placeVM.expandedMedia, case .yelp(let s) = expandedMedia, string == s {
                                    Rectangle()
                                        .foregroundStyle(Color.themeBorder)
                                } else if let url = URL(string: string) {
                                    ImageLoader(url, contentMode: .fill) { progress in
                                        Rectangle()
                                            .foregroundStyle(.clear)
                                            .frame(maxWidth: 150)
                                            .overlay {
                                                ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding(.horizontal)
                                            }
                                    }
                                    .matchedGeometryEffect(id: string.hash, in: namespace)
                                    .aspectRatio(2/3, contentMode: .fill)
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
                    
                    ForEach(vm.medias) { media in
                        ZStack {
                            if let expandedMedia = placeVM.expandedMedia, case .phantom(let m) = expandedMedia, media.id == m.id {
                                Rectangle()
                                    .foregroundStyle(Color.themeBorder)
                            } else {
                                Group {
                                    if media.type == .image, let url = media.src {
                                        ImageLoader(url, contentMode: .fill) { progress in
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .frame(maxWidth: 150)
                                                .overlay {
                                                    ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                        .progressViewStyle(LinearProgressViewStyle())
                                                        .padding(.horizontal)
                                                }
                                        }
                                        .matchedGeometryEffect(id: media.id, in: namespace)
                                        .aspectRatio(2/3, contentMode: .fill)
                                    } else if let thumbnail = media.thumbnail {
                                        ImageLoader(thumbnail, contentMode: .fill) { progress in
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .frame(maxWidth: 150)
                                                .overlay {
                                                    ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                        .progressViewStyle(LinearProgressViewStyle())
                                                        .padding(.horizontal)
                                                }
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
                                }
                                .overlay(alignment: .bottomLeading) {
                                    if let user = media.user {
                                        HStack(spacing: 5) {
                                            ProfileImage(user.profileImage, size: 24, cornerRadius: 12)
                                            
                                            Text(user.name)
                                                .cfont(.caption2)
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
                    
                    Color.clear
                        .frame(width: 0, height: 0)
                        .task {
                            await vm.fetch(type: .new)
                        }
                }
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    PlaceMediaView(placeVM: PlaceVM(id: "645c1d1ab41f8e12a0d166bc"), namespace: Namespace().wrappedValue)
}
