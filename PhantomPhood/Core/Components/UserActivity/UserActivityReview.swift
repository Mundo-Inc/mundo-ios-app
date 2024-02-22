//
//  UserActivityReview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import SwiftUI
import Kingfisher

struct UserActivityReview: View {
    @ObservedObject private var vm: UserActivityVM
    @ObservedObject private var mediasViewModel: MediasVM
    
    init(vm: UserActivityVM, mediasViewModel: MediasVM) {
        self._vm = ObservedObject(wrappedValue: vm)
        self._mediasViewModel = ObservedObject(wrappedValue: mediasViewModel)
    }
    
    @ObservedObject private var commentsViewModel = CommentsVM.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    
    @State private var showActions = false
    
    private func showMedia() {
        guard let data = vm.data else { return }
        
        switch data.resource {
        case .review(let feedReview):
            mediasViewModel.show(medias: feedReview.videos + feedReview.images)
        default:
            return
        }
    }
    
    var body: some View {
        if let data = vm.data {
            UserActivityItemTemplate(user: data.user, comments: data.comments, isActive: commentsViewModel.currentActivityId == data.id) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(data.user.name)
                            .font(.custom(style: .body))
                            .fontWeight(.bold)
                        Spacer()
                        Text(data.createdAt.timeElapsed(suffix: " ago"))
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
                                                    if let url = image.src {
                                                        KFImage.url(url)
                                                            .placeholder {
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .foregroundStyle(Color.themePrimary)
                                                                    .overlay {
                                                                        ProgressView()
                                                                    }
                                                            }
                                                            .loadDiskFileSynchronously()
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
                }
                .confirmationDialog("Actions", isPresented: $showActions) {
                    switch data.resource {
                    case .review(let review):
                        NavigationLink(value: AppRoute.report(id: review.id, type: .review)) {
                            Text("Report")
                        }
                    default:
                        EmptyView()
                    }
                }
            } footer: {
                WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                    Button {
                        selectReactionsViewModel.select { reaction in
                            Task {
                                await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji))
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
                                    await vm.removeReaction(data.reactions.user[selectedIndex])
                                }
                            }
                        } else {
                            ReactionLabel(reaction: reaction, isSelected: false) { _ in
                                Task {
                                    await vm.addReaction(NewReaction(reaction: reaction.reaction, type: .emoji))
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
