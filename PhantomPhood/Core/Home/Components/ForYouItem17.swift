//
//  ForYouItem17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/31/24.
//

import SwiftUI
import Kingfisher
import VideoPlayer
import CoreMedia

struct ForYouItem17: View {
    @ObservedObject private var appData = AppData.shared
    
    let index: Int
    @ObservedObject private var forYouVM: ForYouVM
    let parentGeometry: GeometryProxy
    
    @ObservedObject var videoPlayerVM: VideoPlayerVM
    
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    
    /// For handling multiple video playback
    @State private var tabPage: String = ""
    
    @State private var videosState: [String:VideoPlayer.State] = [:]
    
    /// Calculated from geometryReader
    @State private var totalSize: CGSize
    @State private var contentSize: CGSize
    
    private let scrollPosition: String?
    
    init(index: Int, forYouVM: ForYouVM, parentGeometry: GeometryProxy, scrollPosition: String?) {
        self.index = index
        self._forYouVM = ObservedObject(wrappedValue: forYouVM)
        self.parentGeometry = parentGeometry
        
        self._videoPlayerVM = ObservedObject(wrappedValue: VideoPlayerVM.shared)
        
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
        
        self._totalSize = State(wrappedValue: .init(width: parentGeometry.size.width, height: parentGeometry.size.height + parentGeometry.safeAreaInsets.top))
        self._contentSize = State(wrappedValue: parentGeometry.size)
        
        self.scrollPosition = scrollPosition
    }
    
    @State private var time: CMTime = .zero
    @State private var currentVideoTotalDuration: Double = .zero
    
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
    
    var body: some View {
        ZStack {
            Color.themePrimary
                .onChange(of: self.parentGeometry.size) { value in
                    self.totalSize = .init(width: parentGeometry.size.width, height: parentGeometry.size.height + parentGeometry.safeAreaInsets.top)
                    self.contentSize = value
                }
                .onChange(of: self.parentGeometry.safeAreaInsets.top) { value in
                    self.totalSize = .init(width: parentGeometry.size.width, height: parentGeometry.size.height + parentGeometry.safeAreaInsets.top)
                    self.contentSize = parentGeometry.size
                }
                .onChange(of: scrollPosition) { newValue in
                    if newValue != forYouVM.items[index].id {
                        time = .zero
                    }
                }
            
            switch forYouVM.items[index].resource {
            case .review(let feedReview):
                Color.clear
                    .onChange(of: tabPage) { newTab in
                        if scrollPosition == forYouVM.items[index].id {
                            if feedReview.videos.contains(where: { $0.id == newTab }) {
                                videoPlayerVM.playId = newTab
                            } else {
                                videoPlayerVM.playId = nil
                            }
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
                                        .frame(width: totalSize.width, height: totalSize.height)
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
                            .frame(width: totalSize.width, height: totalSize.height)
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
                        .frame(width: totalSize.width, height: totalSize.height)
                        .contentShape(Rectangle())
                        .clipShape(Rectangle())
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
            
            VStack {
                Spacer()
                
                ZStack {
                    VStack(spacing: 0) {
                        switch forYouVM.items[index].resource {
                        case .review(let feedReview):
                            HStack {
                                VStack(spacing: -15) {
                                    ProfileImage(forYouVM.items[index].user.profileImage, size: 50)
                                    
                                    LevelView(level: forYouVM.items[index].user.progress.level)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 30)
                                }
                                .onTapGesture {
                                    appData.goTo(AppRoute.userProfile(userId: forYouVM.items[index].user.id))
                                }
                                
                                VStack {
                                    Text(forYouVM.items[index].user.name)
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .onTapGesture {
                                            appData.goTo(AppRoute.userProfile(userId: forYouVM.items[index].user.id))
                                        }
                                    
                                    HStack {
                                        if let place = forYouVM.items[index].place {
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
                                            .foregroundStyle(.primary)
                                            .onTapGesture {
                                                appData.goTo(AppRoute.place(id: place.id))
                                            }
                                        } else {
                                            Text("-")
                                        }
                                        
                                        Spacer()
                                        
                                        Text(DateFormatter.getPassedTime(from: forYouVM.items[index].createdAt))
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
                                .scrollIndicators(.never)
                                
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
                            .padding(.bottom)
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
                                VStack(spacing: -15) {
                                    ProfileImage(forYouVM.items[index].user.profileImage, size: 50)
                                    
                                    LevelView(level: forYouVM.items[index].user.progress.level)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 30)
                                }
                                .onTapGesture {
                                    appData.goTo(AppRoute.userProfile(userId: forYouVM.items[index].user.id))
                                }
                                
                                VStack {
                                    Text(forYouVM.items[index].user.name)
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .onTapGesture {
                                            appData.goTo(AppRoute.userProfile(userId: forYouVM.items[index].user.id))
                                        }
                                    
                                    HStack {
                                        if let place = forYouVM.items[index].place {
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
                                            .foregroundStyle(.primary)
                                            .onTapGesture {
                                                appData.goTo(AppRoute.place(id: place.id))
                                            }
                                        } else {
                                            Text("-")
                                        }
                                        
                                        Spacer()
                                        
                                        Text(DateFormatter.getPassedTime(from: forYouVM.items[index].createdAt))
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
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.vertical)
                            .padding(.horizontal)
                            .padding(.trailing, 52)
                            .padding(.trailing)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity)
                            .background {
                                LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                    .allowsHitTesting(false)
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
                                .onTapGesture {
                                    selectReactionsViewModel.select { reaction in
                                        let item = forYouVM.items[index]
                                        Task {
                                            await forYouVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: item)
                                        }
                                    }
                                }
                            
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
                                .onTapGesture {
                                    commentsViewModel.showComments(activityId: forYouVM.items[index].id)
                                }
                        }
                        .frame(width: 52)
                        .padding(.trailing)
                        .padding(.vertical)
                        .padding(.bottom, 80)
                    }
                }
                .frame(width: contentSize.width, height: contentSize.height)
                .font(.custom(style: .body))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
