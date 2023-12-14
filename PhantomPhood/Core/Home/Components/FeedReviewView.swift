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
    @ObservedObject private var commentsViewModel: CommentsViewModel
    @ObservedObject private var mediasViewModel: MediasViewModel
    
    @StateObject private var reactionsViewModel: ReactionsViewModel
    @State private var reactions: ReactionsObject
    @State private var showActions = false
    
    @Binding private var reportId: String?
    
    init(data: FeedItem, commentsViewModel: CommentsViewModel, mediasViewModel: MediasViewModel, reportId: Binding<String?>) {
        self.data = data
        self._commentsViewModel = ObservedObject(wrappedValue: commentsViewModel)
        self._mediasViewModel = ObservedObject(wrappedValue: mediasViewModel)
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: data.id))
        self._reactions = State(wrappedValue: data.reactions)
        self._reportId = reportId
    }
    
    @ObservedObject private var selectReactionsViewModel = SelectReactionsViewModel.shared
    
    private func showMedia() {
        switch data.resource {
        case .review(let feedReview):
            mediasViewModel.show(medias: feedReview.videos + feedReview.images)
        default:
            return
        }
    }
    
    private var starsView: some View {
        HStack(spacing: 0) {
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
        }
        .font(.system(size: 14))
        .foregroundStyle(Color.themeBorder)
    }
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments, isActive: commentsViewModel.currentActivityId == data.id) {
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
                        NavigationLink(value: HomeStack.place(id: place.id)) {
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
                                
                                starsView
                                    .overlay {
                                        GeometryReader(content: { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .foregroundStyle(.yellow)
                                                    .frame(width: (overallScore / 5) * geometry.size.width)
                                            }
                                        })
                                        .mask(starsView)
                                    }
                                
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
                    ZStack {
                        Color.black
                        
                        VStack(spacing: 20) {
                            Button("Report", role: .destructive) {
                                withAnimation {
                                    showActions = false
                                    switch data.resource {
                                    case .review(let review):
                                        reportId = review.id
                                    default:
                                        break
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Cancel", role: .destructive) {
                                withAnimation {
                                    showActions = false
                                    reportId = nil
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .zIndex(100)
                }
            }
        } footer: {
            WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                Button {
                    selectReactionsViewModel.select { reaction in
                        Task {
                            await selectReaction(reaction: reaction)
                        }
                    }
                } label: {
                    Image(systemName: "face.dashed")
                        .font(.system(size: 20))
                        .overlay(alignment: .topTrailing) {
                            Color.themeBG
                                .frame(width: 12, height: 12)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12))
                                }
                                .offset(x: 4, y: -4)
                        }
                    
                }
                
                Button {
                    commentsViewModel.showComments(activityId: data.id)
                } label: {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 20))
                }
                .padding(.horizontal, 5)
                
                ForEach(reactions.total) { reaction in
                    if let selectedIndex = reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                        ReactionLabel(reaction: reaction, isSelected: true) { _ in
                            Task {
                                try await reactionsViewModel.removeReaction(id: String(reactions.user[selectedIndex].id))
                                reactions.total = reactions.total.compactMap({ item in
                                    if item.reaction == reactions.user[selectedIndex].reaction {
                                        if item.count - 1 == 0 {
                                            return nil
                                        }
                                        return Reaction(reaction: item.reaction, type: item.type, count: item.count - 1)
                                    }
                                    return item
                                })
                                reactions.user.remove(at: selectedIndex)
                            }
                        }
                    } else {
                        ReactionLabel(reaction: reaction, isSelected: false) { _ in
                            Task {
                                let newReaction = try await reactionsViewModel.addReaction(type: reaction.type, reaction: reaction.reaction)
                                reactions.user.append(UserReaction(_id: newReaction.id, reaction: newReaction.reaction, type: newReaction.type, createdAt: newReaction.createdAt))
                                if reactions.total.contains(where: { $0.reaction == newReaction.reaction }) {
                                    reactions.total = reactions.total.map({ item in
                                        if item.reaction == newReaction.reaction {
                                            return Reaction(reaction: item.reaction, type: item.type, count: item.count + 1)
                                        }
                                        return item
                                    })
                                } else {
                                    reactions.total.append(Reaction(reaction: newReaction.reaction, type: newReaction.type, count: 1))
                                }
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.primary)
        }
    }
    
    
    private func selectReaction(reaction: NewReaction) async {
        do {
            let newReaction = try await reactionsViewModel.addReaction(type: reaction.type, reaction: reaction.reaction)
            reactions.user.append(UserReaction(_id: newReaction.id, reaction: newReaction.reaction, type: newReaction.type, createdAt: newReaction.createdAt))
            if reactions.total.contains(where: { $0.reaction == newReaction.reaction }) {
                reactions.total = reactions.total.map({ item in
                    if item.reaction == newReaction.reaction {
                        return Reaction(reaction: item.reaction, type: item.type, count: item.count + 1)
                    }
                    return item
                })
            } else {
                reactions.total.append(Reaction(reaction: newReaction.reaction, type: newReaction.type, count: 1))
            }
        } catch {
            print("Error")
        }
    }
    
}

#Preview {
    ScrollView {
        FeedReviewView(
            data: FeedItem(
                id: "64d2aa872c509f60b7690386",
                user: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: [])),
                place: CompactPlace(
                    _id: "64d2a0c62c509f60b768f572",
                    name: "Lavender",
                    amenity: .restaurant,
                    description: "",
                    location: PlaceLocation(geoLocation: .init(lng: 51.56185809999999, lat: 32.8669179), address: "VH86+QPQ, Shahin Shahr, Isfahan Province, Iran", city: "Shahin Shahr", state: "Isfahan Province", country: "Iran", zip: nil),
                    thumbnail: nil,
                    phone: nil,
                    website: nil,
                    categories: ["restaurant"],
                    priceRange: 2,
                    scores: PlaceScores(overall: 5, drinkQuality: 3, foodQuality: 4, atmosphere: 5, service: 4, value: nil, phantom: 82),
                    reviewCount: 1
                ),
                activityType: .newReview,
                resourceType: .review,
                resource: .review(FeedReview(
                    _id: "64d2aa872c509f60b769037e",
                    scores: ReviewScores(overall: 5, drinkQuality: 3, foodQuality: 4, atmosphere: 5, service: 4, value: nil),
                    content: "Cute vibe \nCozy atmosphere \nDelicious pancakes \nCool music \nHighly recommended ",
                    images: [Media(_id: "64d2aa872c509f60b7690379", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image)],
                    videos: [Media(_id: "64d2aa782c509f60b7690376", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/2a667b01b413fd08fd00a60b2f5ba3e1.mp4", caption: "", type: .video)],
                    tags: [],
                    recommend: true,
                    language: "en",
                    createdAt: "2023-08-08T20:50:15.905Z",
                    updatedAt: "2023-08-08T20:50:17.297Z",
                    userActivityId: "64d2aa872c509f60b7690386",
                    writer: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: []))
                )),
                privacyType: .PUBLIC,
                createdAt: "2023-08-08T20:50:15.916Z",
                updatedAt: "2023-08-08T20:50:15.916Z",
                reactions: ReactionsObject(
                    total: [Reaction(reaction: "❤️", type: .emoji, count: 2), Reaction(reaction: "👍", type: .emoji, count: 1), Reaction(reaction: "🥰", type: .emoji, count: 1)],
                    user: [UserReaction(_id: "64d35ef61eff94afe959dd9e", reaction: "❤️", type: .emoji, createdAt: "2023-08-09T09:40:06.866Z")]
                ),
                comments: [
                    Comment(_id: "64d4ee982c9a8ed008970ec3", content: "Hey @nabeel check this out", createdAt: "2023-08-10T14:05:12.743Z", updatedAt: "2023-08-10T14:05:12.743Z", author: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: [])), likes: 2, liked: true, mentions: [])
                ], commentsCount: 10
            ),
            commentsViewModel: CommentsViewModel(),
            mediasViewModel: MediasViewModel(), reportId: .constant(nil)
        )
    }
    .padding(.horizontal)
}
