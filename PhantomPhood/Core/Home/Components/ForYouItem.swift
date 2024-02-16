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
    let index: Int
    @ObservedObject private var forYouVM: ForYouVM
    @ObservedObject private var page: Page
    let parentGeometry: GeometryProxy?
    
    @ObservedObject private var videoPlayerVM = VideoPlayerVM.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    @ObservedObject private var commentsViewModel = CommentsVM.shared
    
    /// For handling multiple video playback
    @State private var tabPage: String = ""
    
    @State private var videosState: [String:VideoPlayer.State] = [:]
    
    init(index: Int, forYouVM: ForYouVM, page: Page, parentGeometry: GeometryProxy?) {
        self.index = index
        self._forYouVM = ObservedObject(wrappedValue: forYouVM)
        self._page = ObservedObject(wrappedValue: page)
        self.parentGeometry = parentGeometry
        
        switch forYouVM.items[index].resource {
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
            
            ZStack {
                switch forYouVM.items[index].resource {
                case .review(let feedReview):
                    Color.clear
                        .onChange(of: tabPage) { newTab in
                            if page.index == index {
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
                                                .animation(.linear(duration: 0.1), value: time.seconds)
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
                                            .fade(duration: 0.25)
                                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.top ?? 0))
                                            .contentShape(Rectangle())
                                            .clipShape(Rectangle())
                                            .ignoresSafeArea(edges: .top)
                                            .tag(image.id)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
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
                                .fade(duration: 0.25)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.top ?? 0))
                                .contentShape(Rectangle())
                                .clipShape(Rectangle())
                                .ignoresSafeArea(edges: .top)
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
                case .checkin(let feedCheckin):
                    if let image = feedCheckin.image, let url = URL(string: image.src) {
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
                            .fade(duration: 0.25)
                            .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.top ?? 0))
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .ignoresSafeArea(edges: .top)
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
            }
            .onTapGesture(count: 2, perform: {
                let item = forYouVM.items[index]
                Task {
                    await forYouVM.addReaction(NewReaction(reaction: "❤️", type: .emoji), to: item)
                }
            })
            .onTapGesture {
                if videoPlayerVM.playId != nil {
                    withAnimation {
                        videoPlayerVM.isMute = !videoPlayerVM.isMute
                    }
                }
            }
            
            LinearGradient(colors: [.black.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
            
            ZStack {
                VStack(spacing: 0) {
                    switch forYouVM.items[index].resource {
                    case .review(let feedReview):
                        HStack {
                            NavigationLink(value: AppRoute.userProfile(userId: forYouVM.items[index].user.id)) {
                                VStack(spacing: -15) {
                                    ProfileImage(forYouVM.items[index].user.profileImage, size: 50)
                                    
                                    LevelView(level: forYouVM.items[index].user.progress.level)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 30)
                                }
                            }
                            
                            VStack {
                                NavigationLink(value: AppRoute.userProfile(userId: forYouVM.items[index].user.id)) {
                                    Text(forYouVM.items[index].user.name)
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundStyle(.white)
                                
                                HStack {
                                    if let place = forYouVM.items[index].place {
                                        NavigationLink(value: AppRoute.place(id: place.id)) {
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
                                    
                                    Text(forYouVM.items[index].createdAt.timeElapsed())
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .background(Material.ultraThin.opacity(0.65))
                        .clipShape(.rect(cornerRadius: 20))
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
                            if let overallScore = feedReview.scores.overall {
                                HStack {
                                    StarRating(score: overallScore, activeColor: Color.gold)
                                    
                                    Text("(\(String(format: "%.0f", overallScore))/5)")
                                        .font(.custom(style: .headline))
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                }
                            }
                            
                            Text(feedReview.content)
                                .lineLimit(5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .padding(.trailing, 52)
                        .padding(.trailing)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .background {
                            LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .allowsHitTesting(false)
                        }
                        .onTapGesture {
                            ForYouInfoVM.shared.show(forYouVM.items[index]) { reaction in
                                let item = forYouVM.items[index]
                                Task {
                                    await forYouVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: item)
                                }
                            }
                        }
                    case .checkin(let feedCheckin):
                        HStack {
                            NavigationLink(value: AppRoute.userProfile(userId: forYouVM.items[index].user.id)) {
                                VStack(spacing: -15) {
                                    ProfileImage(forYouVM.items[index].user.profileImage, size: 50)
                                    
                                    LevelView(level: forYouVM.items[index].user.progress.level)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 30)
                                }
                            }
                            
                            VStack {
                                NavigationLink(value: AppRoute.userProfile(userId: forYouVM.items[index].user.id)) {
                                    Text(forYouVM.items[index].user.name)
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundStyle(.white)
                                
                                HStack {
                                    if let place = forYouVM.items[index].place {
                                        NavigationLink(value: AppRoute.place(id: place.id)) {
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
                                    
                                    Text(forYouVM.items[index].createdAt.timeElapsed())
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .background(Material.ultraThin.opacity(0.65))
                        .clipShape(.rect(cornerRadius: 20))
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        VStack(spacing: 5) {
                            if let tags = feedCheckin.tags {
                                ForEach(tags) { user in
                                    HStack(spacing: 3) {
                                        ProfileImage(user.profileImage, size: 22)
                                        Text("@\(user.username)")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            
                            if let caption = feedCheckin.caption, !caption.isEmpty {
                                Text(caption)
                                    .lineLimit(5)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .padding(.trailing, 52)
                        .padding(.trailing)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .background {
                            if (feedCheckin.caption != nil && !feedCheckin.caption!.isEmpty) || (feedCheckin.tags != nil && !feedCheckin.tags!.isEmpty) {
                                LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                    .allowsHitTesting(false)
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
                        
                        ForEach(Array(forYouVM.items[index].reactions.total.prefix(5))) { reaction in
                            Group {
                                if let selectedIndex = forYouVM.items[index].reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                                    ForYouReactionLabel(reaction: reaction, isSelected: true) { _ in
                                        let item = forYouVM.items[index]
                                        Task {
                                            await forYouVM.removeReaction(item.reactions.user[selectedIndex], from: item)
                                        }
                                    }
                                } else {
                                    ForYouReactionLabel(reaction: reaction, isSelected: false) { _ in
                                        let item = forYouVM.items[index]
                                        Task {
                                            await forYouVM.addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), to: item)
                                        }
                                    }
                                }
                            }
                            .frame(width: 70, height: 34)
                        }
                        
                        if forYouVM.items[index].reactions.total.count > 5 {
                            Text("+ \(forYouVM.items[index].reactions.total.count - 5)")
                                .font(.custom(style: .caption))
                        }
                        
                        Button {
                            selectReactionsViewModel.select { reaction in
                                let item = forYouVM.items[index]
                                Task {
                                    await forYouVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: item)
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
                            commentsViewModel.showComments(activityId: forYouVM.items[index].id)
                        } label: {
                            Capsule()
                                .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: 70, height: 34)
                                .overlay {
                                    HStack {
                                        if forYouVM.items[index].commentsCount > 0 {
                                            Text("\(forYouVM.items[index].commentsCount)")
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
