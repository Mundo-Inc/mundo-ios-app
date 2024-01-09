//
//  UserActivityCheckin.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/9/24.
//

import SwiftUI

struct UserActivityCheckin: View {
    @ObservedObject var vm: UserActivityVM
    
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    @ObservedObject private var selectReactionsViewModel = SelectReactionsVM.shared
    
    var body: some View {
        if let data = vm.data {
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
                    
                    Text("Checked-in")
                        .font(.custom(style: .caption))
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color("CheckedIn"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }.padding(.bottom)
            } content: {
                switch data.resource {
                case .checkin(let checkin):
                    if let place = data.place {
                        VStack {
                            NavigationLink(value: AppRoute.place(id: place.id)) {
                                HStack {
                                    Image(systemName: "checkmark.diamond.fill")
                                        .font(.system(size: 36))
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(LinearGradient(colors: [Color.green, Color.accentColor], startPoint: .topLeading, endPoint: .trailing))
                                    
                                    VStack {
                                        Text(place.name)
                                            .lineLimit(1)
                                            .font(.custom(style: .subheadline))
                                            .foregroundStyle(.primary)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            if let phantomScore = place.scores.phantom {
                                                Text("👻 \(String(format: "%.0f", phantomScore))")
                                                    .bold()
                                                    .foregroundStyle(Color.accentColor)
                                            } else {
                                                Text("TBD")
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            if place.scores.phantom != nil && place.priceRange != nil {
                                                Text(".")
                                            }
                                            
                                            if let priceRange = place.priceRange {
                                                Text(String(repeating: "$", count: priceRange))
                                            }
                                        }
                                        .font(.custom(style: .subheadline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.themePrimary)
                                .clipShape(.rect(cornerRadius: 15))
                            }
                            .foregroundStyle(.primary)
                            
                            Text("\(checkin.totalCheckins) total checkins")
                                .foregroundStyle(.secondary)
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                default:
                    EmptyView()
                }
            } footer: {
                WrappingHStack(horizontalSpacing: 4, verticalSpacing: 6) {
                    Button {
                        selectReactionsViewModel.select { reaction in
                            Task {
                                await vm.addReaction(NewReaction(reaction: reaction.symbol, type: .emoji))
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
