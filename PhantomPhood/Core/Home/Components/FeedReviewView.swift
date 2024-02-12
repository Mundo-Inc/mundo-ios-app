//
//  FeedReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 25.09.2023.
//

import SwiftUI
import Kingfisher

struct FeedReviewView: View {
    private let data: FeedItem
    private let addReaction: (NewReaction, FeedItem) async -> Void
    private let removeReaction: (UserReaction, FeedItem) async -> Void
    
    @ObservedObject private var mediasViewModel: MediasVM

    init(data: FeedItem, addReaction: @escaping (NewReaction, FeedItem) async -> Void, removeReaction: @escaping (UserReaction, FeedItem) async -> Void, mediasViewModel: MediasVM) {
        self.data = data
        self.addReaction = addReaction
        self.removeReaction = removeReaction
        self._mediasViewModel = ObservedObject(wrappedValue: mediasViewModel)
    }
    
    @State private var showActions = false
    @ObservedObject private var commentsViewModel = CommentsVM.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    
    private func showMedia() {
        switch data.resource {
        case .review(let feedReview):
            mediasViewModel.show(medias: feedReview.videos + feedReview.images)
        default:
            return
        }
    }
    
    var body: some View {
        UserActivityItemTemplate(user: data.user, comments: data.comments, isActive: commentsViewModel.currentActivityId == data.id) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(data.user.name)
                        .font(.custom(style: .body))
                        .fontWeight(.bold)
                    Spacer()
                    Text(DateFormatter.getPassedTime(from: data.createdAt, suffix: " ago"))
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Reviewed")
                        .font(.custom(style: .caption))
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color("Reviewed"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    if let place = data.place {
                        NavigationLink(value: AppRoute.place(id: place.id)) {
                            Text(place.name)
                                .font(.custom(style: .body))
                                .bold()
                                .lineLimit(1)
                        }
                        .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showActions = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .padding(.bottom)
        } content: {
            ZStack {
                switch data.resource {
                case .review(let review):
                    VStack {
                        if !review.images.isEmpty || !review.videos.isEmpty {
                            ZStack {
                                GeometryReader(content: { geometry in
                                    TabView {
                                        if !review.videos.isEmpty {
                                            ForEach(review.videos) { video in
                                                ReviewVideoView(url: video.src, mute: true)
                                                    .frame(height: 300)
                                                    .frame(maxWidth: UIScreen.main.bounds.width)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(alignment: .topTrailing) {
                                                        Image(systemName: "video")
                                                            .padding(.top, 8)
                                                            .padding(.trailing, 5)
                                                    }
                                            }
                                        }
                                        if !review.images.isEmpty {
                                            ForEach(review.images) { image in
                                                if let url = URL(string: image.src) {
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
                                                        .frame(height: 300)
                                                        .frame(maxWidth: UIScreen.main.bounds.width)
                                                        .contentShape(Rectangle())
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(alignment: .topTrailing) {
                                                            Image(systemName: "photo")
                                                                .padding(.top, 8)
                                                                .padding(.trailing, 5)
                                                        }
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(.page)
                                })
                            }
                            .onTapGesture {
                                showMedia()
                            }
                            .frame(minHeight: 300)
                        }
                        
                        if let overallScore = review.scores.overall {
                            HStack {
                                Text("Rated")
                                    .font(.custom(style: .headline))
                                    .foregroundStyle(.secondary)
                                
                                Text(String(format: "%.1f", overallScore))
                                    .font(.custom(style: .headline))
                                    .foregroundStyle(.primary)
                                
                                StarRating(score: overallScore, activeColor: .yellow)
                                
                                Spacer()
                            }
                        }
                        
                        Text(review.content)
                            .font(.custom(style: .body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        if let tags = review.tags, !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        Text("#" + tag)
                                    }
                                }
                            }
                            .font(.custom(style: .body))
                            .foregroundStyle(.secondary)
                        }
                    }
                    
                default:
                    EmptyView()
                }
                
                if showActions {
                    VStack {
                        switch data.resource {
                        case .review(let review):
                            NavigationLink(value: AppRoute.report(id: review.id, type: .review)) {
                                Text("Report")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        default:
                            EmptyView()
                        }
                        Button {
                            withAnimation {
                                showActions = false
                            }
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(Color.themeBG)
                    .onDisappear {
                        showActions = false
                    }
                }
            }
        } footer: {
            WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                Button {
                    selectReactionsViewModel.select { reaction in
                        Task {
                            await addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), data)
                        }
                    }
                } label: {
                    Image(.addReaction)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                }
                
                Button {
                    commentsViewModel.showComments(activityId: data.id)
                } label: {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 22))
                        .frame(height: 26)
                }
                .padding(.horizontal, 5)
                
                ForEach(data.reactions.total) { reaction in
                    if let selectedIndex = data.reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                        ReactionLabel(reaction: reaction, isSelected: true) { _ in
                            Task {
                                await removeReaction(data.reactions.user[selectedIndex], data)
                            }
                        }
                    } else {
                        ReactionLabel(reaction: reaction, isSelected: false) { _ in
                            Task {
                                await addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), data)
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.primary)
        }
    }
}
