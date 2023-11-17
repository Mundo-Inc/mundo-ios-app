//
//  FeedLevelUpView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI
import Kingfisher

struct FeedLevelUpView: View {
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
    
    let startDate = Date()
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments, isActive: commentsViewModel.currentActivityId == data.id) {
            HStack {
                switch data.resource {
                case .user(let resourceUser):
                    Text(resourceUser.name)
                        .font(.custom(style: .body))
                        .fontWeight(.bold)
                default:
                    EmptyView()
                }
                
                Text("Leveled Up!")
                    .font(.custom(style: .caption))
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color("LevelUp"))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Spacer()
                
                Text(DateFormatter.getPassedTime(from: data.createdAt, suffix: " ago"))
                    .font(.custom(style: .caption))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
        } content: {
            switch data.resource {
            case .user(let user):
                NavigationLink(value: HomeStack.userProfile(id: user.id)) {
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 54, height: 54)
                                .foregroundStyle(.gray.opacity(0.8))
                            
                            if !user.profileImage.isEmpty, let url = URL(string: user.profileImage) {
                                KFImage.url(url)
                                    .placeholder {
                                        Circle()
                                            .foregroundStyle(Color.themePrimary)
                                            .overlay {
                                                ProgressView()
                                            }
                                    }
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .fade(duration: 0.25)
                                    .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
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
    ScrollView {
        FeedLevelUpView(
            data: FeedItem(
                id: "64d2aa872c509f60b7690386",
                user: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: [])),
                place: nil,
                activityType: .levelUp,
                resourceType: .user,
                resource: .user(User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: []))),
                privacyType: .PUBLIC,
                createdAt: "2023-08-08T20:50:15.916Z",
                updatedAt: "2023-08-08T20:50:15.916Z",
                score: 574.8699489214853,
                weight: 1,
                reactions: ReactionsObject(
                    total: [Reaction(reaction: "❤️", type: .emoji, count: 2), Reaction(reaction: "👍", type: .emoji, count: 1), Reaction(reaction: "🥰", type: .emoji, count: 1)],
                    user: [UserReaction(_id: "64d35ef61eff94afe959dd9e", reaction: "❤️", type: .emoji, createdAt: "2023-08-09T09:40:06.866Z")]
                ),
                comments: [
                    Comment(_id: "64d4ee982c9a8ed008970ec3", content: "Hey @nabeel check this out", createdAt: "2023-08-10T14:05:12.743Z", updatedAt: "2023-08-10T14:05:12.743Z", author: User(_id: "64d29e412c509f60b768f240", name: "Kia", username: "TheKia", bio: "Test Bio", coins: 9, verified: true, profileImage: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", progress: .init(xp: 520, level: 3, achievements: [])), likes: 2, liked: true, mentions: [])
                ]
            ),
            commentsViewModel: CommentsViewModel()
        )
    }
}
