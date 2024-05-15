//
//  UserProfilePostsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/6/24.
//

import SwiftUI

struct UserProfilePostsView: View {
    let user: UserDetail?
    @Binding var activeTab: UserProfileView.UserProfileTab
    
    @EnvironmentObject private var userProfileVM: UserProfileVM
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            if userProfileVM.posts.isEmpty && userProfileVM.loadingSections.contains(.gettingPosts) {
                ForEach(0...20, id: \.self) { _ in
                    Rectangle()
                        .foregroundStyle(Color.themePrimary)
                        .frame(height: 180)
                        .overlay {
                            Rectangle()
                                .stroke(Color.themeBorder, lineWidth: 2)
                        }
                }
            } else {
                ForEach($userProfileVM.posts) { $post in
                    let item = $post.wrappedValue
                    
                    Group {
                        switch item.activityType {
                        case .newCheckin:
                            if case .checkin(let feedCheckin) = item.resource {
                                ZStack {
                                    if let image = feedCheckin.image {
                                        ImageLoader(image.src) { _ in
                                            Image(systemName: "arrow.down.circle.dotted")
                                                .foregroundStyle(.tertiary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    } else {
                                        LinearGradient(
                                            colors: [
                                                Color(hue: 347 / 360, saturation: 0.72, brightness: 0.62),
                                                Color(hue: 341 / 360, saturation: 0.79, brightness: 0.46),
                                                Color(hue: 320 / 360, saturation: 0.86, brightness: 0.52),
                                            ],
                                            startPoint: .topTrailing,
                                            endPoint: .bottomLeading
                                        )
                                        
                                        Image(systemName: "mappin.square")
                                            .font(.system(size: 80))
                                            .foregroundStyle(.tertiary.opacity(0.2))
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.square")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.white.opacity(0.8))
                                                .frame(width: 22, height: 22)
                                                .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 5))
                                            
                                            Text(feedCheckin.place.name)
                                                .lineLimit(1)
                                                .font(.custom(style: .caption))
                                                .fontWeight(.semibold)
                                                .shadow(radius: 2)
                                        }
                                        
                                        if let caption = feedCheckin.caption {
                                            Text(caption)
                                                .lineLimit(3)
                                                .foregroundStyle(Color.white)
                                                .multilineTextAlignment(.leading)
                                                .font(.custom(style: .caption))
                                                .shadow(radius: 2)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.all, 4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .background(LinearGradient(colors: [Color.black.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                        case .newReview:
                            if case .review(let feedReview) = item.resource {
                                ZStack {
                                    if let item = feedReview.medias.first {
                                        switch item.type {
                                        case .image:
                                            ImageLoader(item.src) { _ in
                                                Image(systemName: "arrow.down.circle.dotted")
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        case .video:
                                            ImageLoader(item.thumbnail) { _ in
                                                Image(systemName: "arrow.down.circle.dotted")
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    } else {
                                        LinearGradient(
                                            colors: [
                                                Color(hue: 202 / 360, saturation: 0.79, brightness: 0.5),
                                                Color(hue: 323 / 360, saturation: 0.59, brightness: 0.43),
                                                Color(hue: 284 / 360, saturation: 0.78, brightness: 0.51),
                                            ],
                                            startPoint: .topTrailing,
                                            endPoint: .bottomLeading
                                        )
                                        
                                        Image(systemName: "pencil.and.list.clipboard")
                                            .font(.system(size: 80))
                                            .foregroundStyle(.tertiary.opacity(0.2))
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .top, spacing: 4) {
                                            if let overallScore = feedReview.scores.overall {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Image(systemName: "pencil.and.list.clipboard")
                                                        .frame(width: 22, height: 22)
                                                        
                                                    Image(systemName: "star")
                                                        .frame(width: 22, height: 22)
                                                }
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.white.opacity(0.8))
                                                .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 5))
                                                
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text(item.place?.name ?? "-")
                                                        .lineLimit(1)
                                                        .shadow(radius: 2)
                                                        .frame(height: 22)
                                                    
                                                    Text("\(Int(overallScore))/5")
                                                        .frame(height: 22)
                                                }
                                                .font(.custom(style: .caption))
                                                .fontWeight(.semibold)
                                            } else {
                                                Image(systemName: "pencil.and.list.clipboard")
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(Color.white.opacity(0.8))
                                                    .frame(width: 22, height: 22)
                                                    .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 5))
                                                
                                                if let place = item.place {
                                                    Text(place.name)
                                                        .lineLimit(1)
                                                        .font(.custom(style: .caption))
                                                        .fontWeight(.semibold)
                                                        .shadow(radius: 2)
                                                }
                                            }
                                        }
                                        
                                        if !feedReview.content.isEmpty {
                                            Text(feedReview.content)
                                                .lineLimit(3)
                                                .foregroundStyle(Color.white)
                                                .multilineTextAlignment(.leading)
                                                .font(.custom(style: .caption))
                                                .shadow(radius: 2)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.all, 4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .background(LinearGradient(colors: [Color.black.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                        case .newHomemade:
                            if case .homemade(let homemade) = item.resource {
                                ZStack {
                                    if let item = homemade.media.first {
                                        switch item.type {
                                        case .image:
                                            ImageLoader(item.src) { _ in
                                                Image(systemName: "arrow.down.circle.dotted")
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        case .video:
                                            ImageLoader(item.thumbnail) { _ in
                                                Image(systemName: "arrow.down.circle.dotted")
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    } else {
                                        Image(systemName: "play.slash")
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Image(systemName: "house")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.white.opacity(0.8))
                                            .frame(width: 22, height: 22)
                                            .background(Color.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 5))
                                        
                                        if !homemade.content.isEmpty {
                                            Text(homemade.content)
                                                .lineLimit(3)
                                                .foregroundStyle(Color.white)
                                                .multilineTextAlignment(.leading)
                                                .font(.custom(style: .caption))
                                                .shadow(radius: 2)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.all, 4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .background(LinearGradient(colors: [Color.black.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                        default:
                            Rectangle()
                                .foregroundStyle(Color.themePrimary)
                                .frame(height: 180)
                                .overlay {
                                    Rectangle()
                                        .stroke(Color.themeBorder, lineWidth: 2)
                                    
                                    VStack {
                                        Text(item.activityType.rawValue)
                                        Text("Not Supported")
                                    }
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: mainWindowSize.width * 0.5)
                    .overlay {
                        Rectangle()
                            .stroke(Color.themeBG, lineWidth: 2)
                    }
                    .onAppear {
                        Task {
                            await userProfileVM.loadMorePosts(currentItem: item)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfilePostsView(user: nil, activeTab: .constant(.posts))
        .environmentObject(UserProfileVM(username: "TheKia"))
}
