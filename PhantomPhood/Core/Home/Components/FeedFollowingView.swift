//
//  FeedFollowingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import SwiftUI
import Kingfisher

struct FeedFollowingView: View {
    let data: FeedItem
    
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    
    @StateObject private var reactionsViewModel: ReactionsViewModel
    @State private var reactions: ReactionsObject
    
    init(data: FeedItem) {
        self.data = data
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: data.id))
        self._reactions = State(wrappedValue: data.reactions)
    }
    
    @ObservedObject var selectReactionsViewModel = SelectReactionsVM.shared
    
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
                    Text("Followed")
                        .font(.custom(style: .caption))
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color("Followed"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    switch data.resource {
                    case .user(let resourceUser):
                        Text(resourceUser.name)
                            .font(.custom(style: .body))
                            .fontWeight(.bold)
                    default:
                        EmptyView()
                    }
                }
            }
            .padding(.bottom)
        } content: {
            switch data.resource {
            case .user(let user):
                NavigationLink(value: AppRoute.userProfile(userId: user.id)) {
                    HStack {
                        ProfileImage(user.profileImage, size: 54)
                        
                        Spacer()
                        
                        Text(user.name)
                            .font(.custom(style: .subheadline))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        ZStack {
                            Color(red: 0.14, green: 0.14, blue: 0.14)
                            Image(.profileCardBG)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .foregroundStyle(.primary)
            default:
                EmptyView()
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
    
    func selectReaction(reaction: EmojisManager.Emoji) async {
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
}

#Preview {
    ScrollView {
        FeedFollowingView(
            data: FeedItem(
                id: "64d2aa872c509f60b7690386",
                user: CompactUser(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(level: 3)),
                place: nil,
                activityType: .following,
                resourceType: .user,
                resource: .user(CompactUser(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(level: 3))),
                privacyType: .PUBLIC,
                createdAt: "2023-08-08T20:50:15.916Z",
                updatedAt: "2023-08-08T20:50:15.916Z",
                reactions: ReactionsObject(
                    total: [Reaction(reaction: "❤️", type: .emoji, count: 2), Reaction(reaction: "👍", type: .emoji, count: 1), Reaction(reaction: "🥰", type: .emoji, count: 1)],
                    user: [UserReaction(_id: "64d35ef61eff94afe959dd9e", reaction: "❤️", type: .emoji, createdAt: "2023-08-09T09:40:06.866Z")]
                ),
                comments: [
                    Comment(_id: "64d4ee982c9a8ed008970ec3", content: "Hey @nabeel check this out", createdAt: "2023-08-10T14:05:12.743Z", updatedAt: "2023-08-10T14:05:12.743Z", author: CompactUser(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(level: 3)), likes: 2, liked: true, mentions: [])
                ], commentsCount: 10
            )
        )
    }
}
