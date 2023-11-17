//
//  FeedCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FeedCheckinView: View {
    let data: FeedItem
    @ObservedObject var commentsViewModel: CommentsViewModel
    
    @StateObject var reactionsViewModel: ReactionsViewModel
    @State var reactions: ReactionsObject
    
    init(data: FeedItem, commentsViewModel: CommentsViewModel) {
        self.data = data
        self._commentsViewModel = ObservedObject(wrappedValue: commentsViewModel)
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: data.id))
        self._reactions = State(wrappedValue: data.reactions)
    }
    
    @ObservedObject var selectReactionsViewModel = SelectReactionsViewModel.shared
    
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
                        NavigationLink(value: HomeStack.place(id: place.id)) {
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
                            await selectReaction(reaction: reaction)
                        }
                    }
                } label: {
                    Image(systemName: "face.dashed")
                        .font(.system(size: 20))
                        .overlay(alignment: .topTrailing) {
                            Color.themeBG
                                .frame(width: 12, height: 12)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12))
                                }
                                .offset(x: 4, y: -4)
                        }
                    
                }
                
                Button {
                    commentsViewModel.showComments(activityId: data.id)
                } label: {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 20))
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
    
    func selectReaction(reaction: NewReaction) async {
        do {
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
        } catch {
            print("Error")
        }
    }
}

#Preview {
    Text("TODO")
}
