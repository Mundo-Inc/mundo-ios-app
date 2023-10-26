//
//  FeedFollowingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import SwiftUI

struct FeedFollowingView: View {
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
    
    @StateObject var selectReactionsViewModel = SelectReactionsViewModel.shared
    
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
            }.padding(.bottom)
        } content: {
                switch data.resource {
                case .user(let user):
                    NavigationLink(value: HomeStack.userProfile(id: user.id)) {
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 54, height: 54)
                                    .foregroundStyle(.gray.opacity(0.8))
                                
                                if let profileImage = user.profileImage, let url = URL(string: profileImage) {
                                    AsyncImage(url: url) { phase in
                                        Group {
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                            } else if phase.error != nil {
                                                Circle()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        Image(systemName: "exclamationmark.icloud")
                                                    }
                                            } else {
                                                Circle()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            }
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                                
                            }
                            
                            
                            Spacer()
                            
                            Text(user.name)
                                .font(.custom(style: .subheadline))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            LevelView(level: .convert(level: user.progress.level))
                                .frame(width: 50, height: 50)
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

//#Preview {
//    let dummyJSON = """
//    {
//    "id": "64e8b4ba442f0060b9d9e8d0",
//    "user": {
//      "_id": "645e7f843abeb74ee6248ced",
//      "name": "Nabeel",
//      "username": "naboohoo",
//      "bio": "Im all about the GAINZ 🔥 thats why i eat 🍔",
//      "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg",
//      "level": 6,
//      "verified": true,
//      "coins": 767,
//      "xp": 1752
//    },
//    "activityType": "FOLLOWING",
//    "resourceType": "User",
//    "resource": {
//      "_id": "645c8b222134643c020860a5",
//      "name": "Kia",
//      "username": "TheKia",
//      "bio": "Passionate tech lover. foodie",
//      "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
//      "level": 3,
//      "verified": true,
//      "xp": 532,
//      "coins": 199
//    },
//    "privacyType": "PUBLIC",
//    "createdAt": "2023-08-25T14:03:38.126Z",
//    "updatedAt": "2023-08-25T14:03:38.126Z",
//    "score": 325.45501932777785,
//    "weight": 1,
//    "reactions": {
//      "total": [],
//      "user": []
//    },
//    "comments": []
//    }
//    """
//
//    let dummyFeedItem = decodeFeedItem(from: dummyJSON)
//    
//    return ScrollView {
//        if let d = dummyFeedItem {
//            FeedFollowingView(data: d, commentsViewModel: CommentsViewModel())
//        }
//    }
//}
