//
//  PlaceReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI
import Kingfisher

struct PlaceReviewView: View {
    let reviewIndex: Int
    
    @Binding var reportId: String?
    @ObservedObject var placeReviewsVM: PlaceReviewsViewModel
    @ObservedObject var mediasViewModel: MediasViewModel
    
    @ObservedObject var commentsViewModel = CommentsViewModel.shared
    @ObservedObject var selectReactionsViewModel = SelectReactionsVM.shared
    
    @State var showActions = false
    
    init(placeReviewsVM: PlaceReviewsViewModel, reviewIndex: Int, mediasViewModel: MediasViewModel, reportId: Binding<String?>) {
        self.reviewIndex = reviewIndex
        self._placeReviewsVM = ObservedObject(wrappedValue: placeReviewsVM)
        self._mediasViewModel = ObservedObject(wrappedValue: mediasViewModel)
        self._reportId = reportId
    }
    
    func showMedia() {
        mediasViewModel.show(medias: review.videos + review.images)
    }
    
    var review: PlaceReview {
        placeReviewsVM.reviews[self.reviewIndex]
    }
    
    var body: some View {
        UserActivityItemTemplate(user: review.writer, comments: review.comments, isActive: review.userActivityId != nil && commentsViewModel.currentActivityId == review.userActivityId) {
            HStack {
                VStack {
                    Text(review.writer.name)
                        .font(.custom(style: .body))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(DateFormatter.getPassedTime(from: review.createdAt, format: .full, suffix: " ago"))
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    showActions = true
                } label: {
                    Image(systemName: "ellipsis")
                }
                .confirmationDialog("Actions", isPresented: $showActions) {
                    Button(role: .destructive) {
                        withAnimation {
                            self.reportId = self.review.id
                        }
                    } label: {
                        Text("Report")
                    }
                }
            }
            .padding(.bottom)
        } content: {
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
                            .onTapGesture {
                                showMedia()
                            }
                        })
                    }
                    .frame(minHeight: 300)
                }
                
                if let rScores = review.scores, let overallScore = rScores.overall {
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
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
        } footer: {
            if let userActivityId = review.userActivityId {
                WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                    Button {
                        selectReactionsViewModel.select { reaction in
                            Task {
                                await placeReviewsVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: review)
                            }
                        }
                    } label: {
                        Image(.addReaction)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                    }
                    
                    Button {
                        commentsViewModel.showComments(activityId: userActivityId)
                    } label: {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 22))
                            .frame(height: 26)
                    }
                    .padding(.horizontal, 5)
                    
                    ForEach(review.reactions.total) { reaction in
                        if let selectedIndex = review.reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                            ReactionLabel(reaction: reaction, isSelected: true) { _ in
                                Task {
                                    await placeReviewsVM.removeReaction(review.reactions.user[selectedIndex], from: review)
                                }
                            }
                        } else {
                            ReactionLabel(reaction: reaction, isSelected: false) { _ in
                                Task {
                                    await placeReviewsVM.addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), to: review)
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }
}
