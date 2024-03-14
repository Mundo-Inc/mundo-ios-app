//
//  ForYouInfoView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import SwiftUI

struct ForYouInfoView: View {
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject var commentsViewModel = CommentsVM.shared
    @ObservedObject var selectReactionsViewModel = SelectReactionsVM.shared
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm = ForYouInfoVM.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(width: 100, height: 30)
            
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
                                appData.goTo(AppRoute.place(id: place.id))
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
                            
                            if let followAction = vm.followAction, !vm.isUserSelf {
                                switch followAction {
                                case .follow, .followBack:
                                    Button {
                                        Task {
                                            await vm.follow(id: data.user.id)
                                        }
                                    } label: {
                                        ZStack {
                                            HStack {
                                                Image(systemName: "person.badge.plus")
                                                Text(followAction.rawValue)
                                            }
                                            .opacity(vm.isLoadingFollowState ? 0 : 1)
                                            
                                            if vm.isLoadingFollowState {
                                                ProgressView()
                                            }
                                        }
                                        .font(.custom(style: .body))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background {
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke()
                                        }
                                        .animation(.easeInOut, value: vm.isLoadingFollowState)
                                    }
                                    .disabled(vm.isLoadingFollowState)
                                    .opacity(vm.isLoadingFollowState ? 0.5 : 1)
                                    .foregroundStyle(Color.accentColor)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding()
                        .onTapGesture {
                            appData.goTo(AppRoute.userProfile(userId: data.user.id))
                        }
                        
                        review
                    }
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            selectReactionsViewModel.select(onSelect: vm.handleAddReaction)
                        }
                    } label: {
                        HStack {
                            Image(.addReaction)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            commentsViewModel.showComments(activityId: data.id)
                        }
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
                .padding(.horizontal)
                .padding(.vertical)
            }
        }
        .presentationDetents([.fraction(0.7), .fraction(0.99)])
    }
    
    private var review: some View {
        VStack {
            if let data = vm.data {
                switch data.resource {
                case .review(let feedReview):
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
                        Group {
                            Text(feedReview.writer.name + ": ").bold() + Text(feedReview.content)
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom(style: .body))
                    }
                    
                default:
                    EmptyView()
                }
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
    ForYouInfoView()
}
