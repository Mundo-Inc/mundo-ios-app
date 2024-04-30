//
//  HomeActivityInfoView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import SwiftUI

struct HomeActivityInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm = HomeActivityInfoVM.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if let data = vm.data {
                ScrollView {
                    VStack {
                        if let place = data.place {
                            HStack {
                                PlaceIcon(amenity: place.amenity, size: 34)
                                
                                VStack {
                                    Text(place.name)
                                        .font(.custom(style: .body))
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if let address = place.location.address {
                                        Text(address)
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.leading, 5)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(.rect(cornerRadius: 16))
                            .padding(.horizontal)
                            .onTapGesture {
                                dismiss()
                                AppData.shared.goTo(AppRoute.place(id: place.id))
                            }
                        }
                        
                        HStack {
                            ProfileImage(data.user.profileImage, size: 44)
                            
                            VStack(spacing: 3) {
                                HStack {
                                    Text(data.user.name)
                                        .font(.custom(style: .body))
                                    
                                    LevelView(level: data.user.progress.level)
                                        .frame(width: 24, height: 24)
                                    
                                    Spacer()
                                }
                                
                                Text("@\(data.user.username)")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .onTapGesture {
                            dismiss()
                            AppData.shared.goToUser(data.user.id)
                        }
                        
                        Content()
                    }
                }
                .scrollIndicators(.never)
                .padding(.top)
                
                Divider()
                
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                        SheetsManager.shared.presenting = .reactionSelector(onSelect: vm.handleAddReaction)
                    } label: {
                        HStack {
                            Image(.Icons.addReaction)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 26)
                            
                            Text("\(data.reactions.total.reduce(0) { $0 + $1.count })")
                                .font(.custom(style: .body))
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Button {
                        dismiss()
                        SheetsManager.shared.presenting = .comments(activityId: data.id)
                    } label: {
                        HStack {
                            Image(systemName: "bubble.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 22)
                            
                            Text("\(data.commentsCount)")
                                .font(.custom(style: .body))
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .presentationDetents([.fraction(0.7), .fraction(0.99)])
    }
    
    @ViewBuilder
    private func Content() -> some View {
        if let data = vm.data {
            switch data.activityType {
            case .newCheckin:
                if case .checkin(let feedCheckIn) = data.resource {
                    if let caption = feedCheckIn.caption, !caption.isEmpty {
                        Text(caption)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .body))
                    }
                }
            case .newReview:
                if case .review(let feedReview) = data.resource {
                    VStack {
                        if feedReview.scores.overall != nil || feedReview.scores.atmosphere != nil || feedReview.scores.drinkQuality != nil || feedReview.scores.foodQuality != nil || feedReview.scores.service != nil || feedReview.scores.value != nil {
                            VStack(spacing: 8) {
                                if let score = feedReview.scores.overall {
                                    ScoreItem(title: "Overall Score", score: score)
                                }
                                if let score = feedReview.scores.drinkQuality {
                                    ScoreItem(title: "Drink Quality", score: score)
                                }
                                if let score = feedReview.scores.foodQuality {
                                    ScoreItem(title: "Food Quality", score: score)
                                }
                                if let score = feedReview.scores.service {
                                    ScoreItem(title: "Service", score: score)
                                }
                                if let score = feedReview.scores.atmosphere {
                                    ScoreItem(title: "Atmosphere", score: score)
                                }
                                if let score = feedReview.scores.value {
                                    ScoreItem(title: "Value", score: score)
                                }
                            }
                            .padding()
                            .frame(maxWidth: 280)
                            .background(.thinMaterial)
                            .clipShape(.rect(cornerRadius: 13))
                        }
                        
                        if let recommend = feedReview.recommend, recommend {
                            HStack {
                                Image(.recommendIcon)
                                Text("I Recommend This Place")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.custom(style: .body))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(.rect(cornerRadius: 13))
                        }
                    }
                    .frame(maxWidth: 280)
                    
                    if !feedReview.content.isEmpty {
                        Text("**\(feedReview.writer.name):** feedReview.content")
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .body))
                    }
                }
            case .following:
                if case .users(let users) = data.resource {
                    VStack(spacing: 0) {
                        ForEach(users.indices, id: \.self) { index in
                            let user = users[index]
                            
                            HStack {
                                ProfileImage(user.profileImage, size: 40)
                                
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.custom(style: .headline))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    
                                    Text("@\(user.username)")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let connectionStatus = user.connectionStatus {
                                    if !connectionStatus.followedByUser {
                                        Text("Show Profile")
                                            .frame(height: 20)
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 1))
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text("Following")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .onTapGesture {
                                dismiss()
                                AppData.shared.goToUser(user.id)
                            }
                            
                            if index != users.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.themePrimary, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            case .newHomemade:
                if case .homemade(let homemade) = data.resource {
                    if !homemade.content.isEmpty {
                        Text(homemade.content)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .body))
                    }
                }
            default:
                EmptyView()
            }
        }
    }
}

private struct ScoreItem: View {
    let title: String
    let score: Double
    
    @State var show = false
    
    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: 140, alignment: .leading)
                .font(.custom(style: .body))
                .fontWeight(.medium)
                .onAppear {
                    withAnimation {
                        self.show = true
                    }
                }
            
            AnimatedStarRating(score: score, size: 16, show: show)
        }
    }
}

#Preview {
    HomeActivityInfoView()
}
