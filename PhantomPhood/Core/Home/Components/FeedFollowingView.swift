//
//  FeedFollowingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import SwiftUI

struct FeedFollowingView: View {
    private let data: FeedItem
    private let addReaction: (NewReaction, FeedItem) async -> Void
    private let removeReaction: (UserReaction, FeedItem) async -> Void
    
    init(data: FeedItem, addReaction: @escaping (NewReaction, FeedItem) async -> Void, removeReaction: @escaping (UserReaction, FeedItem) async -> Void) {
        self.data = data
        self.addReaction = addReaction
        self.removeReaction = removeReaction
    }
    
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    
    var body: some View {
        UserActivityItemTemplate(user: data.user, comments: data.comments, isActive: commentsViewModel.currentActivityId == data.id) {
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
                            await addReaction(NewReaction(reaction: reaction.symbol, type: .emoji), data)
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
                                await removeReaction(data.reactions.user[selectedIndex], data)
                            }
                        }
                    } else {
                        ReactionLabel(reaction: reaction, isSelected: false) { _ in
                            Task {
                                await addReaction(NewReaction(reaction: reaction.reaction, type: .emoji), data)
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.primary)
        }
    }
}
