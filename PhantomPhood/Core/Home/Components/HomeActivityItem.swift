//
//  HomeActivityItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/9/24.
//

import SwiftUI
import CoreMedia

struct HomeActivityItem: View {
    static let sideBarWidth: CGFloat = 80
    static let followsItemLimit: Int = 4
    static let defaultReactions: [NewReaction] = [
        .init(reaction: "🥳", type: .emoji),
        .init(reaction: "❤️", type: .emoji),
        .init(reaction: "🍻", type: .emoji)
    ]
    
    @EnvironmentObject private var actionManager: ActionManager
    
    @ObservedObject private var appData = AppData.shared
    
    @AppStorage(K.UserDefaults.isMute) private var isMute = false
    
    @Binding private var item: FeedItem
    @ObservedObject private var vm: HomeVM
    
    @State private var tabPage: String = ""
    
    private let forTab: HomeTab
    
    init(item: Binding<FeedItem>, vm: HomeVM, forTab: HomeTab) {
        self._item = item
        self._vm = ObservedObject(wrappedValue: vm)
        self.forTab = forTab
        
        switch item.wrappedValue.resource {
        case .review(let feedReview):
            if let firstMedia = feedReview.medias.first {
                self._tabPage = State(wrappedValue: firstMedia.id)
            }
        case .homemade(let homemade):
            if let firstMedia = homemade.media.first {
                self._tabPage = State(wrappedValue: firstMedia.id)
            }
        default:
            break
        }
    }
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    @State private var doubleTapCount: Int = 0
    
    var shouldDisplayFooterBackground: Bool {
        switch item.resource {
        case .review(let feedReview):
            return !feedReview.content.isEmpty || feedReview.scores.overall != nil || (feedReview.tags != nil && !feedReview.tags!.isEmpty)
        case .checkin(let feedCheckin):
            if let caption = feedCheckin.caption, !caption.isEmpty {
                return true
            } else if let tags = feedCheckin.tags, !tags.isEmpty {
                return true
            } else {
                return false
            }
        case .homemade(let homemade):
            return !homemade.content.isEmpty || !homemade.tags.isEmpty
        default:
            return false
        }
    }
    
    var hasSidebar: Bool {
        switch item.activityType {
        case .newCheckin, .newReview, .newHomemade:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        ZStack {
            if appData.navStack.isEmpty && appData.activeTab == .home && appData.homeActiveTab == forTab {
                BackgroundContent()
                    .onTapGesture(count: 2, perform: {
                        self.doubleTapCount += 1
                        if doubleTapCount == 1 {
                            Task {
                                await vm.addReaction(NewReaction(reaction: "❤️", type: .emoji), to: $item)
                            }
                        } else {
                            HapticManager.shared.impact(style: .light)
                        }
                    })
                    .onTapGesture {
                        isMute.toggle()
                    }
            }
            
            LinearGradient(
                colors: shouldDisplayFooterBackground ? [.black.opacity(0.3), .clear, .clear, .black.opacity(0.2), .black.opacity(0.5)] : [.black.opacity(0.3), .clear, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                HeaderContent()
                
                if hasSidebar {
                    HStack(spacing: 0) {
                        Content()
                            .frame(maxWidth: .infinity)
                        
                        SideBar()
                            .frame(width: Self.sideBarWidth)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    Content()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, mainWindowSafeAreaInsets.top + HomeView.headerHeight)
            .padding(.bottom) // Because of action button
            
            if doubleTapCount > 0 {
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.tertiary.shadow(.inner(color: Color.red, radius: 20)))
                    .scaleEffect(1 + CGFloat(doubleTapCount) * 0.2)
                    .rotationEffect(.degrees(doubleTapCount == 1 ? 0 : (doubleTapCount % 2 == 0 ? Double.random(in: 2...10) : -Double.random(in: 2...10))))
                    .allowsHitTesting(false)
                    .animation(.bouncy, value: doubleTapCount)
                    .transition(AnyTransition.scale(scale: 2).combined(with: .opacity).animation(.bouncy))
            }
        }
        .onChange(of: doubleTapCount) { newValue in
            if newValue > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if newValue == self.doubleTapCount {
                        self.doubleTapCount = 0
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func BackgroundContent() -> some View {
        switch item.activityType {
        case .newCheckin:
            if case .checkin(let feedCheckin) = item.resource {
                if let image = feedCheckin.image {
                    MediaItem(media: image)
                } else {
                    LinearGradient(
                        colors: [
                            Color(hue: 347 / 360, saturation: 0.56, brightness: 0.39),
                            Color(hue: 341 / 360, saturation: 0.66, brightness: 0.28),
                            Color(hue: 320 / 360, saturation: 0.76, brightness: 0.3),
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    
                    VStack(spacing: 30) {
                        Text("Checked In")
                            .font(.custom(style: .title))
                            .foregroundStyle(Color.white)
                        
                        HStack(spacing: 5) {
                            Text(feedCheckin.place.name)
                                .font(.custom(style: .headline))
                            
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            AppData.shared.goTo(.place(id: feedCheckin.place.id, action: nil))
                        }
                        
                        Image(systemName: "mappin.square")
                            .font(.system(size: 100))
                            .foregroundStyle(.tertiary.opacity(0.2))
                    }
                }
            }
        case .newReview:
            if case .review(let feedReview) = item.resource {
                if feedReview.medias.count > 1 {
                    TabView(selection: $tabPage) {
                        ForEach(feedReview.medias) { item in
                            MediaItem(media: item)
                                .tag(item.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                } else if let media = feedReview.medias.first {
                    MediaItem(media: media)
                } else if let place = item.place {
                    LinearGradient(
                        colors: [
                            Color(hue: 347 / 360, saturation: 0.56, brightness: 0.39),
                            Color(hue: 341 / 360, saturation: 0.66, brightness: 0.28),
                            Color(hue: 320 / 360, saturation: 0.76, brightness: 0.3),
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    
                    VStack(spacing: 30) {
                        Text("Reviewd")
                            .font(.custom(style: .title))
                            .foregroundStyle(Color.white)
                        
                        HStack(spacing: 5) {
                            Text(place.name)
                                .font(.custom(style: .headline))
                            
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            AppData.shared.goTo(.place(id: place.id, action: nil))
                        }
                        
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.system(size: 100))
                            .foregroundStyle(.tertiary.opacity(0.2))
                    }
                }
            }
        case .levelUp:
            if case .user(_) = item.resource {
                LinearGradient(
                    colors: [
                        Color(hue: 202 / 360, saturation: 0.79, brightness: 0.5),
                        Color(hue: 232 / 360, saturation: 0.59, brightness: 0.43),
                        Color(hue: 284 / 360, saturation: 0.78, brightness: 0.51),
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        case .following:
            if case .users(_) = item.resource {
                LinearGradient(
                    colors: [
                        Color(hue: 205 / 360, saturation: 0.76, brightness: 0.29),
                        Color(hue: 178 / 360, saturation: 0.42, brightness: 0.25),
                        Color(hue: 94 / 360, saturation: 0.33, brightness: 0.36),
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        case .newHomemade:
            if case .homemade(let homemade) = item.resource {
                if homemade.media.count > 1 {
                    TabView(selection: $tabPage) {
                        ForEach(homemade.media) { m in
                            MediaItem(media: m)
                                .tag(m.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                } else if let media = homemade.media.first {
                    MediaItem(media: media)
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
    
    @ViewBuilder
    private func HeaderContent() -> some View {
        HStack {
            ProfileImage(item.user.profileImage, size: 54)
                .overlay(alignment: .bottom) {
                    LevelView(level: item.user.progress.level)
                        .shadow(radius: 3)
                        .frame(width: 26, height: 30)
                        .offset(y: 15)
                }
                .onTapGesture {
                    AppData.shared.goToUser(item.user.id)
                }
            
            VStack(spacing: 4) {
                HStack {
                    Text(item.user.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            AppData.shared.goToUser(item.user.id)
                        }
                    
                    if let connectionStatus = item.user.connectionStatus, connectionStatus.followingStatus == .notFollowing {
                        HStack {
                            if vm.loadingSections.contains(.followRequest(item.user.id)) {
                                ProgressView()
                                    .controlSize(.mini)
                            } else {
                                Image(systemName: "plus")
                            }
                        }
                        .frame(width: 25, height: 25)
                        .background(Color.accentColor, in: Circle())
                        .foregroundStyle(Color.white)
                        .onTapGesture {
                            Task {
                                await vm.followUser(item: $item)
                            }
                        }
                    }
                    
                    if Authentication.shared.currentUser?.id != item.user.id {
                        HStack {
                            if self.vm.loadingSections.contains(.startingConversation) {
                                ProgressView()
                                    .controlSize(.mini)
                            } else {
                                Text("Message")
                            }
                        }
                        .frame(height: 25)
                        .frame(maxWidth: 80)
                        .font(.custom(style: .caption))
                        .fontWeight(.regular)
                        .foregroundStyle(Color.primary)
                        .background(Color.accentColor, in: Capsule())
                        .onTapGesture {
                            Task {
                                await self.vm.startConversation(with: item.user.id)
                            }
                        }
                    }
                }
                .frame(height: 25)
                
                Spacer()
                    .frame(minHeight: 0)
                
                HStack() {
                    switch item.activityType {
                    case .newCheckin, .newReview:
                        if let place = item.place {
                            HStack(spacing: 5) {
                                if let amenity = place.amenity {
                                    amenity.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(.Icons.restaurant)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(place.name)
                                    .lineLimit(1)
                                
                                Image(systemName: "chevron.forward")
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.primary)
                            .fontWeight(.semibold)
                            .onTapGesture {
                                AppData.shared.goTo(AppRoute.place(id: place.id))
                            }
                        }
                    case .levelUp, .following, .newHomemade:
                        Text("@\(item.user.username)")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .fontWeight(.medium)
                    default:
                        EmptyView()
                    }
                    
                    Spacer()
                    
                    Text(item.createdAt.timeElapsed())
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 54)
        .padding(.all, 10)
        .background(.ultraThinMaterial.opacity(0.65).shadow(.drop(radius: 5)), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top)
    }
    
    @ViewBuilder
    private func Content() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            switch item.activityType {
            case .newCheckin:
                if case .checkin(let feedCheckin) = item.resource {
                    Spacer()
                    
                    ContentTypeChip(text: "Check In", color: .checkedIn)
                    
                    ForEach(feedCheckin.tags ?? []) { user in
                        TaggedUser(user)
                    }
                    
                    if let caption = feedCheckin.caption, !caption.isEmpty {
                        Text(caption)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .onTapGesture {
                                HomeActivityInfoVM.shared.show(item) { reaction in
                                    Task {
                                        await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                    }
                                }
                            }
                    }
                }
            case .newReview:
                if case .review(let feedReview) = item.resource {
                    Spacer()
                    
                    ContentTypeChip(text: "Review", color: .reviewed)
                        .onTapGesture {
                            HomeActivityInfoVM.shared.show(item) { reaction in
                                Task {
                                    await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                }
                            }
                        }
                    
                    if let overallScore = feedReview.scores.overall {
                        HStack {
                            StarRating(score: overallScore, activeColor: Color.gold)
                            
                            Text("(\(String(format: "%.0f", overallScore))/5)")
                                .font(.custom(style: .headline))
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .onTapGesture {
                            HomeActivityInfoVM.shared.show(item) { reaction in
                                Task {
                                    await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                }
                            }
                        }
                    }
                    
                    if !feedReview.content.isEmpty {
                        Text(feedReview.content)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .onTapGesture {
                                HomeActivityInfoVM.shared.show(item) { reaction in
                                    Task {
                                        await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                    }
                                }
                            }
                    }
                }
            case .levelUp:
                if case .user(let user) = item.resource {
                    VStack {
                        Text("Leveled Up")
                            .font(.custom(style: .title))
                            .foregroundStyle(Color.white)
                        
                        LevelView(level: user.progress.level)
                            .shadow(radius: 10)
                            .frame(maxWidth: 120, maxHeight: 120)
                            .frame(width: mainWindowSize.width / 2, height:  mainWindowSize.width / 2)
                        
                        
                        HStack(spacing: 30) {
                            ForEach(Self.defaultReactions) { r in
                                let selectedIndex = item.reactions.user.firstIndex { $0.reaction == r.reaction && $0.type == r.type }
                                ForYouReactionLabel(
                                    reaction: .init(reaction: r.reaction, type: r.type, count: item.reactions.total.filter({ $0.reaction == r.reaction && $0.type == r.type }).count),
                                    isSelected: selectedIndex != nil,
                                    size: 50,
                                    orientation: .vertical
                                ) { _ in
                                    if let selectedIndex {
                                        Task {
                                            await vm.removeReaction(item.reactions.user[selectedIndex], from: $item)
                                        }
                                    } else {
                                        Task {
                                            await vm.addReaction(r, to: $item)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            case .following:
                if case .users(let users) = item.resource {
                    VStack {
                        Text("Recently Followed")
                            .font(.custom(style: .title))
                            .foregroundStyle(Color.white)
                        
                        VStack(spacing: 0) {
                            let usersList = users.count > Self.followsItemLimit ? Array(users.prefix(Self.followsItemLimit)) : users
                            ForEach(usersList.indices, id: \.self) { index in
                                HStack {
                                    ProfileImage(usersList[index].profileImage, size: 40)
                                    
                                    VStack(alignment: .leading) {
                                        Text(usersList[index].name)
                                            .font(.custom(style: .headline))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        Text("@\(usersList[index].username)")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if let connectionStatus = usersList[index].connectionStatus {
                                        switch connectionStatus.followingStatus {
                                        case .following:
                                            Text("Following")
                                                .font(.custom(style: .caption))
                                                .foregroundStyle(.secondary)
                                        case .notFollowing:
                                            HStack {
                                                if vm.loadingSections.contains(.followRequest(usersList[index].id)) {
                                                    ProgressView()
                                                        .controlSize(.mini)
                                                } else {
                                                    Text(connectionStatus.followedByStatus == .following ? "Follow Back" : "Follow")
                                                }
                                            }
                                            .frame(height: 20)
                                            .frame(minWidth: 60)
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 1))
                                            .onTapGesture {
                                                Task {
                                                    await vm.followResourceUser(item: $item, userId: usersList[index].id)
                                                }
                                            }
                                            .foregroundStyle(.primary)
                                        case .requested:
                                            Text("Requested")
                                                .font(.custom(style: .caption))
                                                .foregroundStyle(.secondary)
                                            
                                        }
                                    }
                                }
                                .padding()
                                .onTapGesture {
                                    AppData.shared.goToUser(usersList[index].id)
                                }
                                
                                if index != usersList.count - 1 {
                                    Divider()
                                }
                            }
                            
                            if users.count > Self.followsItemLimit {
                                Divider()
                                
                                Text("+\(users.count - Self.followsItemLimit) more")
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical)
                                    .onTapGesture {
                                        HomeActivityInfoVM.shared.show(item) { reaction in
                                            Task {
                                                await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.themePrimary, in: RoundedRectangle(cornerRadius: 12))
                        
                    }
                    .frame(maxWidth: .infinity)
                }
            case .newHomemade:
                if case .homemade(let homemade) = item.resource {
                    Spacer()
                    
                    ContentTypeChip(text: "Home Made", color: .homemade)
                    
                    ForEach(homemade.tags) { user in
                        TaggedUser(user)
                    }
                    
                    if !homemade.content.isEmpty {
                        Text(homemade.content)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .onTapGesture {
                                HomeActivityInfoVM.shared.show(item) { reaction in
                                    Task {
                                        await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                                    }
                                }
                            }
                    }
                }
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func SideBar() -> some View {
        VStack(spacing: 6) {
            Spacer()
            
            ForEach(Array(item.reactions.total.prefix(5))) { reaction in
                Group {
                    if let selectedIndex = item.reactions.user.firstIndex(where: { $0.reaction == reaction.reaction }) {
                        ForYouReactionLabel(reaction: reaction, isSelected: true) { _ in
                            Task {
                                await vm.removeReaction(item.reactions.user[selectedIndex], from: $item)
                            }
                        }
                    } else {
                        ForYouReactionLabel(reaction: reaction, isSelected: false) { _ in
                            Task {
                                await vm.addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), to: $item)
                            }
                        }
                    }
                }
                .frame(width: 52, height: 40)
            }
            
            if item.reactions.total.count > 5 {
                Text("+ \(item.reactions.total.count - 5)")
                    .font(.custom(style: .caption))
            }
            
            Image(.Icons.addReaction)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
                .frame(width: 52, height: 52)
                .foregroundStyle(.white)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                .background(.bar.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    SheetsManager.shared.presenting = .reactionSelector(onSelect: { reaction in
                        Task {
                            await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), to: $item)
                        }
                    })
                }
            
            
            VStack(spacing: 0) {
                Image(.Icons.addReview)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: item.commentsCount > 0 ? 26 : 28)
                if item.commentsCount > 0 {
                    Text("\(item.commentsCount)")
                        .font(.custom(style: .caption2))
                }
            }
            .frame(width: 52, height: 52)
            .foregroundStyle(.white)
            .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
            .background(.bar.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                SheetsManager.shared.presenting = .comments(activityId: item.id)
            }
            
            switch item.activityType {
            case .newCheckin:
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        if case .checkin(let checkin) = item.resource {
                            if let currentUser = Authentication.shared.currentUser, currentUser.id == checkin.user.id {
                                actionManager.value = [
                                    .init(title: "Delete", alertMessage: "Are you sure you want to delete this activity?", callback: {
                                        Task {
                                            await deleteCheckin(id: checkin.id)
                                        }
                                    }),
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .checkIn(checkin.id)))
                                    })
                                ]
                            } else {
                                actionManager.value = [
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .checkIn(checkin.id)))
                                    })
                                ]
                            }
                        }
                    }
            case .newReview:
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        if case .review(let review) = item.resource {
                            if let currentUser = Authentication.shared.currentUser, currentUser.id == review.writer.id {
                                actionManager.value = [
                                    .init(title: "Delete Review", alertMessage: "Are you sure you want to delete this review?", callback: {
                                        Task {
                                            await deleteReview(id: review.id)
                                        }
                                    }),
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .review(review.id)))
                                    })
                                ]
                            } else {
                                actionManager.value = [
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .review(review.id)))
                                    })
                                ]
                            }
                        }
                    }
            case .newHomemade:
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        if case .homemade(let homemade) = item.resource {
                            if let currentUser = Authentication.shared.currentUser, currentUser.id == homemade.user.id {
                                actionManager.value = [
                                    .init(title: "Delete", alertMessage: "Are you sure you want to delete this activity?", callback: {
                                        Task {
                                            await deleteHomemade(id: homemade.id)
                                        }
                                    }),
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .homemade(homemade.id)))
                                    })
                                ]
                            } else {
                                actionManager.value = [
                                    .init(title: "Report", callback: {
                                        AppData.shared.goTo(AppRoute.report(item: .homemade(homemade.id)))
                                    })
                                ]
                            }
                        }
                    }
            default:
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.clear)
                    .frame(width: 40, height: 40)
            }
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.clear)
                .frame(width: 40, height: 40)
                .overlay {
                    if isMute {
                        Image(systemName: "speaker.slash.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 24))
                            .transition(AnyTransition.opacity.animation(.easeIn))
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.trailing, 8)
        .padding(.bottom)
    }
}

extension HomeActivityItem {
    @ViewBuilder
    private func MediaItem(media: MediaItem) -> some View {
        if let url = media.src {
            switch media.type {
            case .image:
                ImageLoader(url, contentMode: .fill) { progress in
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(maxWidth: 150)
                        .overlay {
                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.horizontal)
                        }
                }
                .contentShape(.rect)
            case .video:
                switch forTab {
                case .following:
                    VideoPlayer(url: url, playing: vm.followingItemOnViewPort == self.item.id && tabPage == media.id, isMute: isMute)
                case .forYou:
                    VideoPlayer(url: url, playing: vm.forYouItemOnViewPort == self.item.id && tabPage == media.id, isMute: isMute)
                }
            }
        } else {
            Text("Something went wrong!")
        }
    }
    
    @ViewBuilder
    private func ContentTypeChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.custom(style: .caption))
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(color.opacity(0.8))
            .clipShape(.rect(cornerRadius: 5))
    }
    
    @ViewBuilder
    private func TaggedUser(_ user: UserEssentials) -> some View {
        HStack(spacing: 5) {
            ProfileImage(user.profileImage, size: 28)
            
            Text(user.username)
                .font(.custom(style: .caption))
                .foregroundStyle(.white)
                .fontWeight(.medium)
            
            Image(systemName: "chevron.forward")
                .font(.system(size: 10))
                .fontWeight(.bold)
            
            Spacer()
        }
        .onTapGesture {
            AppData.shared.goToUser(user.id)
        }
    }
}

extension HomeActivityItem {
    func deleteReview(id: String) async {
        let reviewDM = ReviewDM()
        do {
            try await reviewDM.remove(reviewId: id)
            ToastVM.shared.toast(.init(type: .success, title: "Deleted", message: "Your review has been deleted"))
            switch forTab {
            case .following:
                await vm.updateFollowingData(.refresh)
            case .forYou:
                await vm.updateForYouData(.refresh)
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func deleteCheckin(id: String) async {
        let checkInDM = CheckInDM()
        do {
            try await checkInDM.deleteOne(byId: id)
            ToastVM.shared.toast(.init(type: .success, title: "Deleted", message: "Your activity has been deleted"))
            switch forTab {
            case .following:
                await vm.updateFollowingData(.refresh)
            case .forYou:
                await vm.updateForYouData(.refresh)
            }
        } catch {
            presentErrorToast(error)
        }
    }
    
    func deleteHomemade(id: String) async {
        let homemadeDM = HomeMadeDM()
        do {
            try await homemadeDM.deleteOne(byId: id)
            ToastVM.shared.toast(.init(type: .success, title: "Deleted", message: "Your activity has been deleted"))
            switch forTab {
            case .following:
                await vm.updateFollowingData(.refresh)
            case .forYou:
                await vm.updateForYouData(.refresh)
            }
        } catch {
            presentErrorToast(error)
        }
    }
}
