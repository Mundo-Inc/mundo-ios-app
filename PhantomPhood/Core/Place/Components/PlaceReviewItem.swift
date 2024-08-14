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
                                .cfont(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(Color.primary)
                        
                        Text(review.createdAt.timeElapsed(suffix: " ago"))
                            .cfont(.caption)
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
                        
                        Image(.Logo.tpLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .background(Color.black, in: Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            if !review.media.isEmpty {
                Group {
                    if review.media.count == 1 {
                        if let first = review.media.first {
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
                                    placeVM.expandedMedia = .init(id: first.id, type: first.type, src: first.src, caption: first.caption, user: nil)
                                }
                            }
                        }
                    } else {
                        ZStack {
                            TabView {
                                ForEach(review.media) { media in
                                    switch media.type {
                                    case .video:
                                        ReviewVideoView(url: media.src, mute: true)
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
                                                    placeVM.expandedMedia = .init(id: media.id, type: media.type, src: media.src, caption: media.caption, user: nil)
                                                }
                                            }
                                    case .image:
                                        ImageLoader(media.src, contentMode: .fill) { progress in
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
                                                placeVM.expandedMedia = .init(id: media.id, type: media.type, src: media.src, caption: media.caption, user: nil)
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
                .cfont(.body)
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
                            .cfont(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("just now")
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(String(repeating: "👻", count: 5))
                            .font(.system(size: 14))
                        
                        Spacer()
                        
                        Image(.Logo.tpLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                            .background(Color.black, in: Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse eu nibh sed nunc venenatis lobortis. Donec at porttitor nunc, ut pellentesque odio.")
                .cfont(.body)
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
        PlaceReviewItem(review: .constant(Placeholder.placeReviews[0]), placeVM: PlaceVM(id: "TEST", action: nil))
    }
    .padding(.vertical)
    .background(Color.themePrimary)
}
