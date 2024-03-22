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
    @Binding private var item: FeedItem
    @ObservedObject private var forYouVM: ForYouVM
    @ObservedObject private var videoPlayerVM: VideoPlayerVM
    
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    @ObservedObject private var commentsViewModel = CommentsVM.shared
    @ObservedObject private var appData = AppData.shared
    
    /// For handling multiple video playback
    @State private var tabPage: String = ""
    
    @State private var videosState: [String:VideoPlayer.State] = [:]
    
    @Binding var scrollPosition: String?
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    init(item: Binding<FeedItem>, forYouVM: ForYouVM, scrollPosition: Binding<String?>) {
        self._item = item
        self._forYouVM = ObservedObject(wrappedValue: forYouVM)
        
        self._videoPlayerVM = ObservedObject(wrappedValue: VideoPlayerVM.shared)
        
        switch item.wrappedValue.resource {
        case .review(let feedReview):
            if let firstVideo = feedReview.videos.first {
                self._tabPage = State(wrappedValue: firstVideo.id)
            } else if let firstImage = feedReview.images.first {
                self._tabPage = State(wrappedValue: firstImage.id)
            }
        default:
            break
        }
        
        self._scrollPosition = scrollPosition
    }
    
    @State private var time: CMTime = .zero
    @State private var currentVideoTotalDuration: Double = .zero
    
    var body: some View {
        ZStack {
            Color.themePrimary
                .onChange(of: scrollPosition) { newValue in
                    if newValue == item.id {
                        // If user changed to next media, start playing correct media
                        switch item.resource {
                        case .review(let feedReview):
                            if !tabPage.isEmpty && feedReview.videos.contains(where: { $0.id == tabPage })  {
                                videoPlayerVM.playId = tabPage
                            }
                        case .homemade(let homemade):
                            if !tabPage.isEmpty && homemade.media.contains(where: { $0.id == tabPage && $0.type == .video })  {
                                videoPlayerVM.playId = tabPage
                            }
                        default:
                            break
                        }
                    } else {
                        time = .zero
                    }
                }
            
            if appData.activeTab == .home && appData.homeActiveTab == .forYou && appData.homeNavStack.isEmpty { // Stop video if user navigates
                ZStack {
                    switch item.resource {
                    case .review(let feedReview):
                        Color.clear
                            .onChange(of: tabPage) { newTab in
                                if scrollPosition == item.id {
                                    if feedReview.videos.contains(where: { $0.id == newTab }) {
                                        videoPlayerVM.playId = newTab
                                    } else {
                                        videoPlayerVM.playId = nil
                                    }
                                }
                            }
                        
                        if feedReview.images.count + feedReview.videos.count > 1 {
                            TabView(selection: $tabPage) {
                                ForEach(feedReview.videos) { video in
                                    ZStack {
                                        if let url = video.src {
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
                                    .ignoresSafeArea(edges: .top)
                                    .overlay(alignment: .bottomLeading) {
                                        if !time.seconds.isZero, !currentVideoTotalDuration.isZero {
                                            Rectangle()
                                                .frame(height: 2)
                                                .frame(width: mainWindowSize.width * (time.seconds / currentVideoTotalDuration))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .tag(video.id)
                                }
                                
                                ForEach(feedReview.images) { image in
                                    if let url = image.src {
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
                                            .frame(width: mainWindowSize.width, height: mainWindowSize.height)
                                            .contentShape(Rectangle())
                                            .clipShape(Rectangle())
                                            .ignoresSafeArea(edges: .top)
                                            .tag(image.id)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                        } else {
                            if let image = feedReview.images.first, let url = image.src {
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
                                    .frame(width: mainWindowSize.width, height: mainWindowSize.height)
                                    .contentShape(Rectangle())
                                    .clipShape(Rectangle())
                                    .ignoresSafeArea(edges: .top)
                            } else if let video = feedReview.videos.first, let url = video.src {
                                ZStack {
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
                                .ignoresSafeArea(edges: .top)
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
                        if let image = feedCheckin.image, let url = image.src {
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
                                .frame(width: mainWindowSize.width, height: mainWindowSize.height)
                                .contentShape(Rectangle())
                                .clipShape(Rectangle())
                                .ignoresSafeArea(edges: .top)
                        }
                    case .homemade(let homemade):
                        Color.clear
                            .onChange(of: tabPage) { newTab in
                                if scrollPosition == item.id {
                                    if homemade.media.contains(where: { $0.id == newTab && $0.type == .video }) {
                                        videoPlayerVM.playId = newTab
                                    } else {
                                        videoPlayerVM.playId = nil
                                    }
                                }
                            }
                        
                        if homemade.media.count > 1 {
                            TabView(selection: $tabPage) {
                                ForEach(homemade.media) { m in
                                    if m.type == .video {
                                        ZStack {
                                            if let url = m.src {
                                                VideoPlayer(url: url, play: playBinding(for: m.id), time: $time)
                                                    .onStateChanged { state in
                                                        videosState.updateValue(state, forKey: m.id)
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
                                            
                                            if let state = videosState[m.id] {
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
                                        .ignoresSafeArea(edges: .top)
                                        .overlay(alignment: .bottomLeading) {
                                            if !time.seconds.isZero, !currentVideoTotalDuration.isZero {
                                                Rectangle()
                                                    .frame(height: 2)
                                                    .frame(width: mainWindowSize.width * (time.seconds / currentVideoTotalDuration))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .tag(m.id)
                                    } else {
                                        if let url = m.src {
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
                                                .frame(width: mainWindowSize.width, height: mainWindowSize.height)
                                                .contentShape(Rectangle())
                                                .clipShape(Rectangle())
                                                .ignoresSafeArea(edges: .top)
                                                .tag(m.id)
                                        } else {
                                            EmptyView()
                                                .tag(m.id)
                                        }
                                    }
                                    
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                        } else {
                            if let first = homemade.media.first, let url = first.src {
                                if first.type == .video {
                                    ZStack {
                                        VideoPlayer(url: url, play: playBinding(for: first.id), time: $time)
                                            .onStateChanged { state in
                                                videosState.updateValue(state, forKey: first.id)
                                                switch state {
                                                case .playing(let totalDuration):
                                                    currentVideoTotalDuration = totalDuration
                                                default:
                                                    break
                                                }
                                            }
                                            .autoReplay(true)
                                            .mute(videoPlayerVM.isMute)
                                        
                                        if let state = videosState[first.id] {
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
                                    .ignoresSafeArea(edges: .top)
                                    .overlay(alignment: .bottomLeading) {
                                        if !time.seconds.isZero, !currentVideoTotalDuration.isZero {
                                            Rectangle()
                                                .frame(height: 2)
                                                .frame(width: UIScreen.main.bounds.width * (time.seconds / currentVideoTotalDuration))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                } else {
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
                                        .frame(width: mainWindowSize.width, height: mainWindowSize.height)
                                        .contentShape(Rectangle())
                                        .clipShape(Rectangle())
                                        .ignoresSafeArea(edges: .top)
                                }
                            }
                        }
                    default:
                        VStack {
                            Text("Unable to load\nPlease Skip this")
                                .font(.custom(style: .headline))
                            Text("New features are coming. Please check for app update soon")
                                .font(.custom(style: .body))
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    }
                }
                .onTapGesture(count: 2, perform: {
                    Task {
                        await forYouVM.addReaction(NewReaction(reaction: "❤️", type: .emoji), to: $item)
                    }
                })
                .onTapGesture {
                    if videoPlayerVM.playId != nil {
                        withAnimation {
                            videoPlayerVM.isMute = !videoPlayerVM.isMute
                        }
                    }
                }
            }
            
            LinearGradient(colors: [.black.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
            
            ZStack {
                VStack(spacing: 0) {
                    switch item.resource {
                    case .review(let feedReview):
                        HStack {
                            VStack(spacing: -15) {
                                ProfileImage(item.user.profileImage, size: 50)
                                
                                LevelView(level: item.user.progress.level)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 30)
                            }
                            .onTapGesture {
                                appData.goTo(AppRoute.userProfile(userId: item.user.id))
                            }
                            
                            VStack {
                                Text(item.user.name)
                                    .font(.custom(style: .headline))
                                    .frame(height: 18)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        appData.goTo(AppRoute.userProfile(userId: item.user.id))
                                    }
                                
                                HStack {
                                    if let place = item.place {
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
                                    
                                    Text(item.createdAt.timeElapsed())
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
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Review")
                                .font(.custom(style: .caption))
                                .fontWeight(.medium)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color("Reviewed").opacity(0.8))
                                .clipShape(.rect(cornerRadius: 5))
                            
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
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .allowsHitTesting(false)
                        }
                        .onTapGesture {
                            ForYouInfoVM.shared.show(item) { reaction in
                                Task {
                                    await forYouVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                }
                            }
                        }
                    case .checkin(let feedCheckin):
                        HStack {
                            VStack(spacing: -15) {
                                ProfileImage(item.user.profileImage, size: 50)
                                
                                LevelView(level: item.user.progress.level)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 30)
                            }
                            .onTapGesture {
                                appData.goTo(AppRoute.userProfile(userId: item.user.id))
                            }
                            
                            VStack {
                                Text(item.user.name)
                                    .font(.custom(style: .headline))
                                    .frame(height: 18)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        appData.goTo(AppRoute.userProfile(userId: item.user.id))
                                    }
                                
                                HStack {
                                    if let place = item.place {
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
                                        .onTapGesture {
                                            appData.goTo(AppRoute.place(id: place.id))
                                        }
                                    } else {
                                        Text("-")
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.createdAt.timeElapsed())
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
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Check in")
                                .font(.custom(style: .caption))
                                .fontWeight(.medium)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color("CheckedIn").opacity(0.8))
                                .clipShape(.rect(cornerRadius: 5))
                            
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            if (feedCheckin.caption != nil && !feedCheckin.caption!.isEmpty) || (feedCheckin.tags != nil && !feedCheckin.tags!.isEmpty) {
                                LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                    .allowsHitTesting(false)
                            }
                        }
                    case .homemade(let homemade):
                        HStack {
                            VStack(spacing: -15) {
                                ProfileImage(item.user.profileImage, size: 50)
                                
                                LevelView(level: item.user.progress.level)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 30)
                            }
                            .onTapGesture {
                                appData.goTo(AppRoute.userProfile(userId: item.user.id))
                            }
                            
                            VStack {
                                Text(item.user.name)
                                    .font(.custom(style: .headline))
                                    .frame(height: 18)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        appData.goTo(AppRoute.userProfile(userId: item.user.id))
                                    }
                                
                                HStack {
                                    if let user = item.place {
                                        Text(user.name)
                                            .lineLimit(1)
                                    } else {
                                        Text("-")
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.createdAt.timeElapsed())
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
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Home Made")
                                .font(.custom(style: .caption))
                                .fontWeight(.medium)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color("Homemade").opacity(0.8))
                                .clipShape(.rect(cornerRadius: 5))
                            
                            Text(homemade.content)
                                .lineLimit(5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .padding(.trailing, 52)
                        .padding(.trailing)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                        
                        ForEach(Array(item.reactions.total.prefix(5))) { reaction in
                            Group {
                                if let selectedIndex = item.reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                                    ForYouReactionLabel(reaction: reaction, isSelected: true) { _ in
                                        let item = item
                                        Task {
                                            await forYouVM.removeReaction(item.reactions.user[selectedIndex], from: item)
                                        }
                                    }
                                } else {
                                    ForYouReactionLabel(reaction: reaction, isSelected: false) { _ in
                                        Task {
                                            await forYouVM.addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), to: $item)
                                        }
                                    }
                                }
                            }
                            .frame(width: 70, height: 34)
                        }
                        
                        if item.reactions.total.count > 5 {
                            Text("+ \(item.reactions.total.count - 5)")
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
                                    Task {
                                        await forYouVM.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                    }
                                }
                            }
                        
                        Capsule()
                            .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                            .foregroundStyle(.ultraThinMaterial)
                            .frame(width: 70, height: 34)
                            .overlay {
                                HStack {
                                    if item.commentsCount > 0 {
                                        Text("\(item.commentsCount)")
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
                                commentsViewModel.showComments(activityId: item.id)
                            }
                    }
                    .frame(width: 52)
                    .padding(.trailing)
                    .padding(.vertical)
                    .padding(.bottom, 80)
                }
            }
            .padding(.top, mainWindowSafeAreaInsets.top + 40)
            .font(.custom(style: .body))
        }
        .onDisappear {
            // Reset tab page to frist media
            switch item.resource {
            case .review(let feedReview):
                if !tabPage.isEmpty, let firstMedia = feedReview.videos.first ?? feedReview.images.first {
                    tabPage = firstMedia.id
                }
            default:
                break
            }
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
