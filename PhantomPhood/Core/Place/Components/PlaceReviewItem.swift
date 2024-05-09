//
//  PlaceReviewItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/22/24.
//

import SwiftUI

struct PlaceReviewItem: View {
    @Binding var review: PlaceReview
    @ObservedObject var placeVM: PlaceVM
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink(value: AppRoute.userProfile(userId: review.writer.id)) {
                    ProfileImage(review.writer.profileImage, size: 52, cornerRadius: 8)
                }
                
                VStack(spacing: 2) {
                    HStack {
                        NavigationLink(value: AppRoute.userProfile(userId: review.writer.id)) {
                            Text(review.writer.name)
                                .font(.custom(style: .headline))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(Color.primary)
                        
                        Text(review.createdAt.timeElapsed(suffix: " ago"))
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        if let overallScore = review.scores?.overall {
                            HStack(spacing: 0) {
                                Text(String(repeating: "👻", count: Int(overallScore)))
                                Text(String(repeating: "👻", count: 5 - Int(overallScore)))
                                    .opacity(0.3)
                            }
                            .font(.system(size: 14))
                        }
                        
                        Spacer()
                        
                        Image(.phantomPortrait)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .clipShape(Circle())
                            .background(Circle().foregroundStyle(.black))
                    }
                }
            }
            .padding(.horizontal)
            
            if !review.videos.isEmpty || !review.images.isEmpty {
                Group {
                    if review.images.count + review.videos.count == 1 {
                        if let first = review.videos.first ?? review.images.first {
                            Group {
                                switch first.type {
                                case .image:
                                    ImageLoader(first.src, contentMode: .fill) { progress in
                                        Rectangle()
                                            .foregroundStyle(.clear)
                                            .frame(maxWidth: 150)
                                            .overlay {
                                                ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding(.horizontal)
                                            }
                                    }
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "photo")
                                            .padding(.top, 8)
                                            .padding(.trailing, 5)
                                    }
                                case .video:
                                    ReviewVideoView(url: first.src, mute: true)
                                        .frame(height: 300)
                                        .frame(maxWidth: UIScreen.main.bounds.width)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(alignment: .topTrailing) {
                                            Image(systemName: "video")
                                                .padding(.top, 8)
                                                .padding(.trailing, 5)
                                        }
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    placeVM.expandedMedia = .phantom(.init(id: first.id, src: first.src, caption: first.caption, type: first.type, user: nil))
                                }
                            }
                        }
                    } else {
                        ZStack {
                            TabView {
                                if !review.videos.isEmpty {
                                    ForEach(review.videos) { video in
                                        ReviewVideoView(url: video.src, mute: true)
                                            .frame(height: 300)
                                            .frame(maxWidth: UIScreen.main.bounds.width)
                                            .clipShape(.rect(cornerRadius: 8))
                                            .overlay(alignment: .topTrailing) {
                                                Image(systemName: "video")
                                                    .padding(.top, 8)
                                                    .padding(.trailing, 5)
                                            }
                                            .onTapGesture {
                                                withAnimation {
                                                    placeVM.expandedMedia = .phantom(.init(id: video.id, src: video.src, caption: video.caption, type: video.type, user: nil))
                                                }
                                            }
                                    }
                                }
                                if !review.images.isEmpty {
                                    ForEach(review.images) { image in
                                        if let url = image.src {
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
                                            .frame(height: 300)
                                            .clipShape(.rect(cornerRadius: 10))
                                            .overlay(alignment: .topTrailing) {
                                                Image(systemName: "photo")
                                                    .padding(.top, 8)
                                                    .padding(.trailing, 5)
                                            }
                                            .onTapGesture {
                                                withAnimation {
                                                    placeVM.expandedMedia = .phantom(.init(id: image.id, src: image.src, caption: image.caption, type: image.type, user: nil))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: 8))
                .padding(.horizontal)
                .frame(height: 300)
            }
            
            Text(review.content)
                .font(.custom(style: .body))
                .foregroundStyle(Color.primary.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Divider()
        }
    }
}

extension PlaceReviewItem {
    static var placeholder: some View {
        VStack {
            HStack {
                ProfileImage(nil, size: 52, cornerRadius: 8)
                
                VStack(spacing: 2) {
                    HStack {
                        Text("Writer Name")
                            .font(.custom(style: .headline))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("just now")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(String(repeating: "👻", count: 5))
                            .font(.system(size: 14))
                        
                        Spacer()
                        
                        Image(.phantomPortrait)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .clipShape(Circle())
                            .background(Circle().foregroundStyle(.black))
                    }
                }
            }
            .padding(.horizontal)
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse eu nibh sed nunc venenatis lobortis. Donec at porttitor nunc, ut pellentesque odio.")
                .font(.custom(style: .body))
                .foregroundStyle(Color.primary.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Divider()
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    VStack {
        PlaceReviewItem(review: .constant(
            PlaceReview(
                id: "TESTID",
                scores: .init(overall: 4, drinkQuality: nil, foodQuality: nil, atmosphere: nil, service: nil, value: nil),
                content: "This is the content",
                images: [],
                videos: [],
                tags: nil,
                recommend: true,
                language: nil,
                createdAt: .now,
                updatedAt: .now,
                userActivityId: "UserActivityId",
                writer: UserEssentials(id: "UserId", name: "Test User", username: "TestUser", verified: false, isPrivate: false, profileImage: nil, progress: .init(level: 72, xp: 8920), connectionStatus: nil),
                comments: [],
                reactions: .init(
                    total: [.init(reaction: "❤️", type: .emoji, count: 4), .init(reaction: "😍", type: .emoji, count: 2)],
                    user: [.init(id: "Test", reaction: "😍", type: .emoji, createdAt: .now)]
                )
            )
        ), placeVM: PlaceVM(id: "TEST"))
    }
    .padding(.vertical)
    .background(Color.themePrimary)
}
