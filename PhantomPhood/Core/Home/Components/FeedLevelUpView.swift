//
//  FeedLevelUpView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedLevelUpView: View {
    let data: FeedItem
    @State var showComments = false
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments) {
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
                            
                            ZStack {
                                LevelView(level: .convert(level: user.level - 1))
                                    .frame(width: 36, height: 36)
                                    .offset(y: -15)
                                    .opacity(0.5)
                                    

                                LevelView(level: .convert(level: user.level))
                                    .frame(width: 50, height: 50)
                                    .offset(y: 10)
                                    .shadow(radius: 10)
                            }
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
                    showComments = true
                } label: {
                    Image(systemName: "bubble")
                        .font(.system(size: 20))
                }
                .padding(.leading, 5)
                
                Spacer()
            }
            .foregroundStyle(.primary)
        }
        .sheet(isPresented: $showComments, content: {
            CommentsView(activityId: data.id)
        })
    }
}

#Preview {
    let dummyJSON = """
    {
      "id": "64de246354e42fd88a38fd89",
      "user": {
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
      "activityType": "LEVEL_UP",
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
      "createdAt": "2023-08-17T13:45:07.422Z",
      "updatedAt": "2023-08-17T13:45:07.422Z",
      "score": 469.5168030777778,
      "weight": 1,
      "reactions": {
        "total": [
          {
            "count": 1,
            "type": "emoji",
            "reaction": "👍"
          }
        ],
        "user": [
          {
            "_id": "64de248e54e42fd88a38ff73",
            "type": "emoji",
            "reaction": "👍",
            "createdAt": "2023-08-17T13:45:50.666Z"
          }
        ]
      },
      "comments": []
    }
    """
    let dummyFeedItem = decodeFeedItem(from: dummyJSON)
    
    return ScrollView {
        if let d = dummyFeedItem {
            FeedLevelUpView(data: d)
        }
    }
    .padding(.horizontal)
}
