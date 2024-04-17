//
//  EventMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import SwiftUI

struct EventMediaView: View {
    @StateObject private var vm: EventMediaVM
    @ObservedObject private var eventVM: EventVM
    private let namespace: Namespace.ID
    
    init(eventVM: EventVM, namespace: Namespace.ID) {
        self._vm = StateObject(wrappedValue: EventMediaVM(eventVM: eventVM))
        self._eventVM = ObservedObject(wrappedValue: eventVM)
        self.namespace = namespace
    }
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            if let medias = vm.medias {
                if medias.isEmpty {
                    Text("No media")
                        .font(.custom(style: .subheadline))
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                        .padding(.horizontal)
                } else {
                    ForEach(medias) { media in
                        ZStack {
                            if let expandedMedia = eventVM.expandedMedia, media.id == expandedMedia.id {
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
                                eventVM.expandedMedia = media
                            }
                        }
                    }
                    
                    Color.clear
                        .frame(width: 0, height: 0)
                        .task {
                            await vm.fetch(type: .new)
                        }
                }
            } else {
                Group {
                    if eventVM.event != nil {
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
            }
        }
        .padding(.bottom, 40)
    }
}
