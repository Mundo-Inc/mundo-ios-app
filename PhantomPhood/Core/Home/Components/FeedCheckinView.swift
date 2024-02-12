//
//  FeedCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI
import Kingfisher

struct FeedCheckinView: View {
    private let data: FeedItem
    private let addReaction: (NewReaction, FeedItem) async -> Void
    private let removeReaction: (UserReaction, FeedItem) async -> Void
    
    init(data: FeedItem, addReaction: @escaping (NewReaction, FeedItem) async -> Void, removeReaction: @escaping (UserReaction, FeedItem) async -> Void) {
        self.data = data
        self.addReaction = addReaction
        self.removeReaction = removeReaction
    }
    
    @ObservedObject private var commentsViewModel = CommentsVM.shared
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
                            if let image = checkin.image, let url = URL(string: image.src) {
                                ZStack {
                                    KFImage.url(url)
                                        .placeholder { progress in
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .frame(maxWidth: 150)
                                                .overlay {
                                                    ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                        .progressViewStyle(LinearProgressViewStyle())
                                                }
                                        }
                                        .loadDiskFileSynchronously()
                                        .fade(duration: 0.25)
                                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .contentShape(RoundedRectangle(cornerRadius: 15))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                    
                                    if checkin.caption != nil || (checkin.tags != nil && !checkin.tags!.isEmpty) {
                                        VStack(spacing: 5) {
                                            VStack {
                                                Text(place.name)
                                                    .foregroundStyle(Color.white)
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
                                                    }
                                                    
                                                    if let priceRange = place.priceRange {
                                                        if place.scores.phantom != nil {
                                                            Circle()
                                                                .frame(width: 4, height: 4)
                                                                .foregroundStyle(Color.white.opacity(0.4))
                                                        }
                                                        
                                                        Text(String(repeating: "$", count: priceRange))
                                                    }
                                                }
                                                .font(.custom(style: .subheadline))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .frame(maxWidth: .infinity)
                                            
                                            Spacer()
                                            
                                            if let tags = checkin.tags {
                                                ForEach(tags) { user in
                                                    HStack(spacing: 3) {
                                                        ProfileImage(user.profileImage, size: 22)
                                                        Text("@\(user.username)")
                                                            .font(.custom(style: .caption))
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                            }
                                            
                                            if let caption = checkin.caption, !caption.isEmpty {
                                                Text(caption)
                                                    .font(.custom(style: .caption))
                                                    .lineLimit(6)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        .padding()
                                        .background {
                                            LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.4), .clear, .clear, .black.opacity(0.4), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                VStack(spacing: 5) {
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
                                                }
                                                
                                                if let priceRange = place.priceRange {
                                                    if place.scores.phantom != nil {
                                                        Circle()
                                                            .frame(width: 4, height: 4)
                                                            .foregroundStyle(Color.primary.opacity(0.5))
                                                    }
                                                    
                                                    Text(String(repeating: "$", count: priceRange))
                                                }
                                            }
                                            .font(.custom(style: .subheadline))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    
                                    if let tags = checkin.tags {
                                        ForEach(tags) { user in
                                            HStack(spacing: 3) {
                                                ProfileImage(user.profileImage, size: 22)
                                                Text("@\(user.username)")
                                                    .font(.custom(style: .caption))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                    
                                    if let caption = checkin.caption, !caption.isEmpty {
                                        Text(caption)
                                            .lineLimit(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.primary)
                                            .font(.custom(style: .caption))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.themePrimary)
                                .clipShape(.rect(cornerRadius: 15))
                            }
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
