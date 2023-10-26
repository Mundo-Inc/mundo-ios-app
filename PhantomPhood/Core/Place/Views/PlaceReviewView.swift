//
//  PlaceReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct PlaceReviewView: View {
    let review: PlaceReview
    let place: Place
    
    @ObservedObject var commentsViewModel: CommentsViewModel
    @ObservedObject var mediasViewModel: MediasViewModel
    
    @StateObject var reactionsViewModel: ReactionsViewModel
    @State var reactions: ReactionsObject
    
    init(review: PlaceReview, place: Place, commentsViewModel: CommentsViewModel, mediasViewModel: MediasViewModel) {
        self.review = review
        self.place = place
        self._commentsViewModel = ObservedObject(wrappedValue: commentsViewModel)
        self._mediasViewModel = ObservedObject(wrappedValue: mediasViewModel)
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: review.userActivityId ?? ""))
        self._reactions = State(wrappedValue: review.reactions)
    }
    
    @StateObject var selectReactionsViewModel = SelectReactionsViewModel.shared

    func showMedia() {
        mediasViewModel.show(medias: review.videos + review.images)
    }
    
    var starsView: some View {
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
        FeedItemTemplate(user: review.writer, comments: review.comments, isActive: review.userActivityId != nil && commentsViewModel.currentActivityId == review.userActivityId) {
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
                    // TODO: Implement reporting
                } label: {
                    Text("...")
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
                                            CacheAsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .foregroundStyle(Color.themePrimary)
                                                        .overlay {
                                                            ProgressView()
                                                        }
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                default:
                                                    VStack(spacing: 0) {
                                                        Image(systemName: "exclamationmark.icloud")
                                                            .font(.system(size: 50))
                                                            .foregroundStyle(.red)
                                                            .frame(width: 50, height: 50)
                                                        Text("Error")
                                                            .font(.custom(style: .caption))
                                                    }
                                                    .background(Color.themeBG)
                                                }
                                            }
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
                        commentsViewModel.showComments(activityId: userActivityId)
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
    }
    
    func selectReaction(reaction: NewReaction) async {
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
        PlaceReviewView(
            review: PlaceReview(
                _id: "650bc9579baae711358b230f",
                scores: ReviewScores(overall: 4, drinkQuality: 4, foodQuality: nil, atmosphere: 4, service: 4, value: nil),
                content: "The bar is connected to Foreign Cinema, a famous restaurant right next door. You can order food there too.\n\nCocktail menu and drinks are up to par.",
                images: [Media(_id: "650bc9579baae711358b2300", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/f4ac18ac6dcbab332fbad134daecaef1.jpg", caption: nil, type: .image), Media(_id: "650bc9579baae711358b2304", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/6eaba08269af8e32939b41532da92234.jpg", caption: nil, type: .image)],
                videos: [Media(_id: "646eb444891c082d77a02e3b", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/6fbc43dcd6d58df1fbc41df26aac0277.mp4", caption: nil, type: .video)],
                tags: ["gourmet_cuisine", "craft_beers", "innovative_cocktails", "delicious_desserts", "excellent_service"],
                recommend: true,
                language: "en",
                createdAt: "2023-09-21T04:40:55.129+00:00",
                updatedAt: "2023-09-21T04:40:57.442+00:00",
                userActivityId: "650bc9579baae711358b2319",
                writer: User(
                    _id: "64b5a0bad66d45323e935bda",
                    name: "Ross Ahya",
                    username: "RossAhya",
                    bio: "",
                    coins: 49,
                    verified: false,
                    profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg",
                    progress: .init(xp: 127, level: 2, achievements: [])
                ),
                comments: [Comment(_id: "650d0a189baae711358b3cd4", content: "These look deliciousss", createdAt: "2023-09-22T03:29:28.386+00:00", updatedAt: "2023-09-22T03:29:28.386+00:00", author: User(_id: "645e7f843abeb74ee6248ced", name: "Nabeel", username: "naboohoo", bio: "Im all about the GAINZ 🔥 thats why i eat 🍔", coins: 1503, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg", progress: .init(xp: 2207, level: 7, achievements: [])), likes: 0, liked: false, mentions: [])],
                reactions: ReactionsObject(total: [], user: [])
            ),
            place: Place(_id: "645c1d1ab41f8e12a0d166bc", name: "Eleven Madison Park", amenity: .cafe, otherNames: [], description: "Eleven Madison Park embodies an urbane sophistication serving Chef Daniel Humm's modern, sophisticated French cuisine that emphasizes purity, simplicity and seasonal flavors and ingredients.  Daniel's delicate and precise cooking style is experienced through a constantly evolving menu. The restaurant's dramatically high ceilings and magnificent art deco dining room offer guests lush views of historic Madison Square Park and the Flatiron building. In addition to the main dining room, guests may also enjoy wine, beer, and cocktails, as well as an extensive bar menu in the restaurant's bar and Flatiron Lounge.\n\nIn November 2008, Eleven Madison Park was designated Grand Chef Relais & Châteaux, joining the ranks of one of the world's most exclusive associations of hotels and gourmet restaurants. In 2009, Eleven Madison Park received a Four Star Review from The New York Times. The restaurant was also awarded one Michelin star.", location: PlaceLocation(geoLocation: PlaceLocation.GeoLocation(lng: 40.7416907417333, lat: -73.9872074872255), address: "11 Madison Ave", city: "New York", state: "NY", country: "US", zip: "10010"), thumbnail: "https://s3-media1.fl.yelpcdn.com/bphoto/s_H7gm_Hwmz--O6bo1iU-A/o.jpg", phone: "+12128890905", website: "http://www.elevenmadisonpark.com/menus/", categories: ["newamerican", "french", "cocktailbars"], priceRange: 4, scores: PlaceScores(overall: 3.808333333333333, drinkQuality: 4.363636363636363, foodQuality: 3.9342105263157894, atmosphere: 4.205882352941177, service: 4.196428571428571, value: 2.4025974025974026, phantom: 76.41102086767721), reviewCount: 120, reviews: [], thirdParty: Place.ThirdPartyResults(google: nil, yelp: nil), media: []), commentsViewModel: CommentsViewModel(), mediasViewModel: MediasViewModel())
    }
    .padding(.horizontal)

}
