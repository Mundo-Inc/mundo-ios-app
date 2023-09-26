//
//  FeedFollowingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import SwiftUI

struct FeedFollowingView: View {
    let data: FeedItem
    @StateObject var vm = FeedItemViewModel()
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments) {
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
                            
                            LevelView(level: .convert(level: user.level))
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
            HStack {
                Button {
                    
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
                    vm.showComments = true
                } label: {
                    Image(systemName: "bubble")
                        .font(.system(size: 20))
                }
                .padding(.leading, 5)
                
                Spacer()
            }
            .foregroundStyle(.primary)
        }
        .sheet(isPresented: $vm.showComments, content: {
            CommentsView(commentsLoading: $vm.commentsLoading, comments: $vm.comments, commentContent: $vm.commentContent, FeedItemId: data.id) {
                await vm.getComments(id: data.id)
            }
        })
    }
}

fileprivate let dummyJSON = """
{
"id": "64e8b4ba442f0060b9d9e8d0",
"user": {
  "_id": "645e7f843abeb74ee6248ced",
  "name": "Nabeel",
  "username": "naboohoo",
  "bio": "Im all about the GAINZ 🔥 thats why i eat 🍔",
  "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/profile.jpg",
  "level": 6,
  "verified": true,
  "coins": 767,
  "xp": 1752
},
"activityType": "FOLLOWING",
"resourceType": "User",
"resource": {
  "_id": "645c8b222134643c020860a5",
  "name": "Kia",
  "username": "TheKia",
  "bio": "Passionate tech lover. foodie",
  "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
  "level": 3,
  "verified": true,
  "xp": 532,
  "coins": 199
},
"privacyType": "PUBLIC",
"createdAt": "2023-08-25T14:03:38.126Z",
"updatedAt": "2023-08-25T14:03:38.126Z",
"score": 325.45501932777785,
"weight": 1,
"reactions": {
  "total": [],
  "user": []
},
"comments": []
}
"""

fileprivate let dummyFeedItem = decodeFeedItem(from: dummyJSON)

#Preview {
    ScrollView {
        if let d = dummyFeedItem {
            FeedFollowingView(data: d)
        }
    }
}
