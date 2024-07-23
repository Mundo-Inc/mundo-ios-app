//
//  UserActivityCheckin.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import SwiftUI

struct UserActivityCheckin: View {
    @EnvironmentObject private var actionManager: ActionManager
    
    @ObservedObject private var vm: UserActivityVM
    @ObservedObject private var mediaItemsVM: MediaItemsVM
    
    init(vm: UserActivityVM, mediaItemsVM: MediaItemsVM) {
        self._vm = ObservedObject(wrappedValue: vm)
        self._mediaItemsVM = ObservedObject(wrappedValue: mediaItemsVM)
    }
    
    @State private var showActions = false
    
    private func showMedia() {
        guard let data = vm.data else { return }
        
        switch data.resource {
        case .review(let feedReview):
            if let media = feedReview.media {
                mediaItemsVM.show(media)
            }
        default:
            return
        }
    }
    
    var body: some View {
        if let data = vm.data {
            UserActivityItemTemplate(user: data.user, comments: data.comments) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(data.user.name)
                            .cfont(.body)
                            .fontWeight(.bold)
                        Spacer()
                        Text(data.createdAt.timeElapsed(suffix: " ago"))
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Checked-in")
                            .cfont(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.checkedIn)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        if let place = data.place {
                            NavigationLink(value: AppRoute.place(id: place.id)) {
                                Text(place.name)
                                    .cfont(.body)
                                    .bold()
                                    .lineLimit(1)
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button {
                            actionManager.value = [
                                .init(title: "Report", callback: {
                                    if case .checkin(let checkIn) = data.resource {
                                        AppData.shared.goTo(AppRoute.report(item: .checkIn(checkIn.id)))
                                    }
                                })
                            ]
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }.padding(.bottom)
            } content: {
                ZStack {
                    if case .checkin(let checkIn) = data.resource {
                        VStack {
                            if let media = checkIn.media, !media.isEmpty {
                                ZStack {
                                    TabView {
                                        ForEach(media) { item in
                                            switch item.type {
                                            case .video:
                                                ReviewVideoView(url: item.src, mute: true)
                                                    .frame(height: 300)
                                                    .frame(maxWidth: UIScreen.main.bounds.width)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(alignment: .topTrailing) {
                                                        Image(systemName: "video")
                                                            .padding(.top, 8)
                                                            .padding(.trailing, 5)
                                                    }
                                            case .image:
                                                ImageLoader(item.src, contentMode: .fill) { progress in
                                                    Rectangle()
                                                        .foregroundStyle(.clear)
                                                        .frame(maxWidth: 150)
                                                        .overlay {
                                                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                                .progressViewStyle(LinearProgressViewStyle())
                                                        }
                                                }
                                                .frame(height: 300)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(alignment: .topTrailing) {
                                                    Image(systemName: "photo")
                                                        .padding(.top, 8)
                                                        .padding(.trailing, 5)
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(.page)
                                }
                                .onTapGesture {
                                    showMedia()
                                }
                                .frame(minHeight: 300)
                            }
                            
                            if let tags = checkIn.tags {
                                VStack(spacing: 5) {
                                    ForEach(tags) { user in
                                        TaggedUser(user)
                                    }
                                }
                            }
                            
                            Text("\(checkIn.totalCheckins) total checkins")
                                .foregroundStyle(.secondary)
                                .cfont(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
            } footer: {
                WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                    Button {
                        SheetsManager.shared.presenting = .reactionSelector(onSelect: { reaction in
                            Task {
                                await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji))
                            }
                        })
                    } label: {
                        Image(.Icons.addReaction)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                    }
                    
                    Button {
                        SheetsManager.shared.presenting = .comments(activityId: data.id)
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
    
    @ViewBuilder
    private func TaggedUser(_ user: UserEssentials) -> some View {
        HStack(spacing: 5) {
            ProfileImage(user.profileImage, size: 28)
            
            Text(user.username)
                .cfont(.caption)
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
