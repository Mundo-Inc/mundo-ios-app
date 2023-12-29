//
//  ForYouItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/16/23.
//

import SwiftUI
import Kingfisher
import VideoPlayer
import SwiftUIPager
import CoreMedia

struct ForYouItem: View {
    private let data: FeedItem
    private let itemIndex: Int?
    @ObservedObject private var page: Page
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    let parentGeometry: GeometryProxy?
    
    
    @StateObject private var reactionsViewModel: ReactionsViewModel
    @State private var reactions: ReactionsObject
    
    @ObservedObject var videoPlayerVM: VideoPlayerVM
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    
    @State private var tabPage: String = ""
    
    @State private var videosState: [String:VideoPlayer.State] = [:]
    
    init(data: FeedItem, itemIndex: Int?, page: Page, parentGeometry: GeometryProxy?) {
        self.data = data
        self.itemIndex = itemIndex
        self._page = ObservedObject(wrappedValue: page)
        self.parentGeometry = parentGeometry
        
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: data.id))
        self._reactions = State(wrappedValue: .init(total: data.reactions.total.sorted { $0.count > $1.count }, user: data.reactions.user))
        
        self._videoPlayerVM = ObservedObject(wrappedValue: VideoPlayerVM.shared)
        
        switch data.resource {
        case .review(let feedReview):
            if let firstVideo = feedReview.videos.first {
                self._tabPage = State(wrappedValue: firstVideo.id)
            } else if let firstImage = feedReview.images.first {
                self._tabPage = State(wrappedValue: firstImage.id)
            }
        default:
            break
        }
    }
    
    @State private var time: CMTime = .zero
    @State private var currentVideoTotalDuration: Double = .zero
    
    var body: some View {
        ZStack {
            Color.themePrimary
            
            switch data.resource {
            case .review(let feedReview):
                Color.clear
                    .onChange(of: tabPage) { newTab in
                        if page.index == itemIndex {
                            if feedReview.videos.contains(where: { $0.id == newTab }) {
                                videoPlayerVM.playId = newTab
                            } else {
                                videoPlayerVM.playId = nil
                            }
                        } else {
                            videoPlayerVM.playId = nil
                        }
                    }
                
                if feedReview.images.count + feedReview.videos.count > 1 {
                    ZStack {
                        TabView(selection: $tabPage) {
                            ForEach(feedReview.videos) { video in
                                ZStack {
                                    if let url = URL(string: video.src) {
                                        VideoPlayer(url: url, play: playBinding(for: video.id), time: $time)
                                            .onStateChanged { state in
                                                videosState.updateValue(state, forKey: video.id)
                                                switch state {
                                                case .playing(let totalDuration):
                                                    currentVideoTotalDuration = totalDuration
                                                default:
                                                    break
                                                }
                                            }
                                            .autoReplay(true)
                                            .mute(videoPlayerVM.isMute)
                                            .onTapGesture {
                                                withAnimation {
                                                    videoPlayerVM.isMute = !videoPlayerVM.isMute
                                                }
                                            }
                                    }
                                    
                                    if let state = videosState[video.id] {
                                        switch state {
                                        case .loading:
                                            ProgressView()
                                        case .error(let err):
                                            Text("Something went wrong\n\(err.localizedDescription)")
                                        default:
                                            EmptyView()
                                        }
                                    }
                                }
                                .overlay(alignment: .bottomLeading) {
                                    if !time.seconds.isZero, !currentVideoTotalDuration.isZero {
                                        Rectangle()
                                            .animation(.linear, value: time.seconds)
                                            .frame(height: 2)
                                            .frame(width: UIScreen.main.bounds.width * (time.seconds / currentVideoTotalDuration))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .tag(video.id)
                            }
                            
                            ForEach(feedReview.images) { image in
                                if let url = URL(string: image.src) {
                                    KFImage.url(url)
                                        .placeholder { progress in
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .frame(maxWidth: 150)
                                                .overlay {
                                                    ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                        .progressViewStyle(LinearProgressViewStyle())
                                                }
                                        }
                                        .loadDiskFileSynchronously()
                                        .cacheMemoryOnly()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.bottom ?? 0))
                                        .contentShape(Rectangle())
                                        .clipShape(Rectangle())
                                        .tag(image.id)
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                } else {
                    if let image = feedReview.images.first, let url = URL(string: image.src) {
                        KFImage.url(url)
                            .placeholder { progress in
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(maxWidth: 150)
                                    .overlay {
                                        ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                            .progressViewStyle(LinearProgressViewStyle())
                                    }
                            }
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.bottom ?? 0))
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                    } else if let video = feedReview.videos.first {
                        ZStack {
                            if let url = URL(string: video.src) {
                                VideoPlayer(url: url, play: playBinding(for: video.id), time: $time)
                                    .onStateChanged { state in
                                        videosState.updateValue(state, forKey: video.id)
                                        switch state {
                                        case .playing(let totalDuration):
                                            currentVideoTotalDuration = totalDuration
                                        default:
                                            break
                                        }
                                    }
                                    .autoReplay(true)
                                    .mute(videoPlayerVM.isMute)
                                    .onTapGesture {
                                        withAnimation {
                                            videoPlayerVM.isMute = !videoPlayerVM.isMute
                                        }
                                    }
                            }
                            
                            if let state = videosState[video.id] {
                                switch state {
                                case .loading:
                                    ProgressView()
                                case .error(let err):
                                    Text("Something went wrong\n\(err.localizedDescription)")
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        .overlay(alignment: .bottomLeading) {
                            if !time.seconds.isZero, !currentVideoTotalDuration.isZero {
                                Rectangle()
                                    .animation(.linear, value: time.seconds)
                                    .frame(height: 2)
                                    .frame(width: UIScreen.main.bounds.width * (time.seconds / currentVideoTotalDuration))
                                    .foregroundStyle(.white)
                            }
                        }
                        .tag(video.id)
                        
                    }
                }
            default:
                VStack {
                    Text("Unable to load\nPlease Skip this")
                        .font(.custom(style: .headline))
                    Text("We'll make sure you won't experience this again in the future updates.")
                        .font(.custom(style: .body))
                        .padding()
                }
            }
            
            LinearGradient(colors: [.black.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
            
            ZStack {
                VStack(spacing: 0) {
                    switch data.resource {
                    case .review(let feedReview):
                        HStack {
                            NavigationLink(value: HomeStack.userProfile(userId: data.user.id)) {
                                VStack(spacing: -15) {
                                    ProfileImage(data.user.profileImage, size: 50)
                                    
                                    LevelView(level: data.user.progress.level)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 30)
                                }
                            }
                            
                            VStack {
                                NavigationLink(value: HomeStack.userProfile(userId: data.user.id)) {
                                    Text(data.user.name)
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundStyle(.white)
                                
                                HStack {
                                    if let place = data.place {
                                        NavigationLink(value: HomeStack.place(id: place.id)) {
                                            HStack {
                                                if let amenity = place.amenity {
                                                    Image(systemName: amenity.image)
                                                } else {
                                                    Image(systemName: "fork.knife")
                                                }
                                                
                                                Text(place.name)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .foregroundStyle(.primary)
                                    } else {
                                        Text("-")
                                    }
                                    
                                    Spacer()
                                    
                                    Text(DateFormatter.getPassedTime(from: data.createdAt))
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .background(Material.ultraThin.opacity(0.7))
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        if videoPlayerVM.playId != nil && videoPlayerVM.isMute {
                            Image(systemName: "speaker.slash.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .transition(.move(edge: .leading))
                        }
                        
                        VStack(spacing: 5) {
                            ScrollView(.horizontal) {
                                HStack(spacing: 4) {
                                    ForEach(feedReview.videos) { vid in
                                        Image(systemName: "video")
                                            .animation(.easeInOut, value: tabPage)
                                            .foregroundStyle(vid.id == tabPage ? Color.accentColor : Color.secondary)
                                    }
                                    ForEach(feedReview.images) { img in
                                        Image(systemName: "photo")
                                            .foregroundStyle(img.id == tabPage ? Color.accentColor : Color.secondary)
                                    }
                                }
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .scrollIndicators(.hidden)
                            
                            if let overallScore = feedReview.scores.overall {
                                HStack {
                                    StarRating(score: overallScore)
                                    
                                    Text("(\(String(format: "%.0f", overallScore))/5)")
                                        .font(.custom(style: .headline))
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                }
                            }
                            
                            Text(feedReview.content)
                                .lineLimit(5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .padding(.trailing, 52)
                        .padding(.trailing)
                        .frame(maxWidth: .infinity)
                        .background {
                            LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .allowsHitTesting(false)
                        }
                        .onTapGesture {
                            ForYouInfoVM.shared.show(data) { reaction in
                                Task {
                                    await selectReaction(reaction: reaction)
                                }
                            }
                        }
                        
                    default:
                        EmptyView()
                    }
                }
                .padding(.top)
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Spacer()
                        
                        ForEach(Array(reactions.total.prefix(5))) { reaction in
                            Group {
                                if let selectedIndex = reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                                    ForYouReactionLabel(reaction: reaction, isSelected: true) { _ in
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
                                    ForYouReactionLabel(reaction: reaction, isSelected: false) { _ in
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
                            .frame(width: 70, height: 34)
                        }
                        
                        if reactions.total.count > 5 {
                            Text("+ \(reactions.total.count - 5)")
                                .font(.custom(style: .caption))
                        }
                        
                        Button {
                            selectReactionsViewModel.select { reaction in
                                Task {
                                    await selectReaction(reaction: reaction)
                                }
                            }
                        } label: {
                            Capsule()
                                .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: 70, height: 34)
                                .overlay {
                                    Image(.addReaction)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 24)
                                        .foregroundStyle(.white)
                                }
                        }
                        
                        Button {
                            commentsViewModel.showComments(activityId: data.id)
                        } label: {
                            Capsule()
                                .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: 70, height: 34)
                                .overlay {
                                    HStack {
                                        if data.commentsCount > 0 {
                                            Text("\(data.commentsCount)")
                                                .font(.custom(style: .body))
                                        }
                                        Image(systemName: "bubble.left")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(height: 20)
                                    .foregroundStyle(.white)
                                }
                        }
                        .padding(.horizontal, 5)
                    }
                    .frame(width: 52)
                    .padding(.trailing)
                    .padding(.vertical)
                    .offset(y: -80)
                }
            }
            .font(.custom(style: .body))
            .padding(.top, parentGeometry?.safeAreaInsets.top)
        }
        .frame(maxWidth: .infinity)
    }
    
    func selectReaction(reaction: EmojiesManager.Emoji) async {
        do {
            let newReaction = try await reactionsViewModel.addReaction(type: .emoji, reaction: reaction.symbol)
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
    
    private func playBinding(for videoId: String) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                return self.videoPlayerVM.playId == videoId
            },
            set: { isPlaying in
                // Update the playId only if necessary to prevent unnecessary view refreshes
                if isPlaying && self.videoPlayerVM.playId != videoId {
                    self.videoPlayerVM.playId = videoId
                } else if !isPlaying && self.videoPlayerVM.playId == videoId {
                    self.videoPlayerVM.playId = nil
                }
            }
        )
    }
}

#Preview {
    ForYouItem(
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
                scores: PlaceScores(overall: 4, drinkQuality: 3, foodQuality: 4, atmosphere: 5, service: 4, value: nil, phantom: 82),
                reviewCount: 1
            ),
            activityType: .newReview,
            resourceType: .review,
            resource: .review(FeedReview(
                _id: "64d2aa872c509f60b769037e",
                scores: ReviewScores(overall: 4, drinkQuality: 3, foodQuality: 4, atmosphere: 5, service: 4, value: nil),
                content: "Cute vibe \nCozy atmosphere \nDelicious pancakes \nCool music \nHighly recommended ",
                images: [Media(_id: "64d2aa872c509f60b7690389", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690370", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690371", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690372", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690373", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690374", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690375", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690376", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690377", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690378", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690379", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690390", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690321", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image), Media(_id: "64d2aa872c509f60b7690322", src: "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg", caption: "", type: .image)],
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
                total: [Reaction(reaction: "❤️", type: .emoji, count: 2), Reaction(reaction: "👍", type: .emoji, count: 1), Reaction(reaction: "🥰", type: .emoji, count: 1), Reaction(reaction: "A", type: .emoji, count: 2), Reaction(reaction: "B", type: .emoji, count: 1), Reaction(reaction: "C", type: .emoji, count: 1), Reaction(reaction: "D", type: .emoji, count: 2), Reaction(reaction: "E", type: .emoji, count: 1), Reaction(reaction: "F", type: .emoji, count: 1)],
                user: [UserReaction(_id: "64d35ef61eff94afe959dd9e", reaction: "❤️", type: .emoji, createdAt: "2023-08-09T09:40:06.866Z")]
            ),
            comments: [
                Comment(_id: "64d4ee982c9a8ed008970ec3", content: "Hey @nabeel check this out", createdAt: "2023-08-10T14:05:12.743Z", updatedAt: "2023-08-10T14:05:12.743Z", author: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: [])), likes: 2, liked: true, mentions: [])
            ], commentsCount: 10
        ),
        itemIndex: 2,
        page: Page.first(),
        parentGeometry: nil
    )
}
