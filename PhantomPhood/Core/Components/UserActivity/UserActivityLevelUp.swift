//
//  UserActivityLevelUp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import SwiftUI

struct UserActivityLevelUp: View {
    @ObservedObject var vm: UserActivityVM
    
    // For shader
    private let startDate = Date()
    
    var body: some View {
        if let data = vm.data {
            UserActivityItemTemplate(user: data.user, comments: data.comments) {
                HStack {
                    switch data.resource {
                    case .user(let resourceUser):
                        Text(resourceUser.name)
                            .cfont(.body)
                            .fontWeight(.bold)
                    default:
                        EmptyView()
                    }
                    
                    Text("Leveled Up!")
                        .cfont(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color("LevelUp"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    Spacer()
                    
                    Text(data.createdAt.timeElapsed(suffix: " ago"))
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
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
                                .cfont(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                            
                            Spacer()
                            
                            ZStack {
                                LevelView(level: user.progress.level - 1)
                                    .frame(width: 36, height: 36)
                                    .offset(y: -15)
                                    .opacity(0.4)
                                
                                
                                LevelView(level: user.progress.level)
                                    .frame(width: 50, height: 50)
                                    .offset(y: 10)
                                    .shadow(radius: 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            if #available(iOS 17.0, *) {
                                TimelineView(.animation) { context in
                                    Color(red: 0.14, green: 0.14, blue: 0.14)
                                        .colorEffect(ShaderLibrary.circleLoader(.boundingRect, .float(startDate.timeIntervalSinceNow)))
                                }
                            } else {
                                ZStack {
                                    Color(red: 0.14, green: 0.14, blue: 0.14)
                                    Image(.profileCardBG)
                                        .resizable()
                                        .scaledToFill()
                                }
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
}
