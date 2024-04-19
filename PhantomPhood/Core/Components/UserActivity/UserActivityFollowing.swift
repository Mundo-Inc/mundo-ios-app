//
//  UserActivityFollowing.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import SwiftUI

struct UserActivityFollowing: View {
    @ObservedObject var vm: UserActivityVM
    
    var body: some View {
        if let data = vm.data {
            UserActivityItemTemplate(user: data.user, comments: data.comments) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(data.user.name)
                            .font(.custom(style: .body))
                            .fontWeight(.bold)
                        Spacer()
                        Text(data.createdAt.timeElapsed(suffix: " ago"))
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
                        SelectReactionsVM.shared.select { reaction in
                            Task {
                                await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji))
                            }
                        }
                    } label: {
                        Image(.Icons.addReaction)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 26)
                    }
                    
                    Button {
                        CommentsVM.shared.showComments(activityId: data.id)
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
}
