//
//  FeedReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 25.09.2023.
//

import SwiftUI

struct FeedReviewView: View {
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
  "id": "64d2aa872c509f60b7690386",
  "user": {
    "_id": "64d29e412c509f60b768f240",
    "name": "Soli",
    "username": "solimkr2001",
    "bio": "PharmD stu\nInfluencer \nAlways on a diet",
    "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/64d29e412c509f60b768f240/profile.jpg",
    "xp": 57,
    "level": 1,
    "verified": true,
    "coins": 9
  },
  "place": {
    "_id": "64d2a0c62c509f60b768f572",
    "name": "Lavender",
    "otherNames": [],
    "description": "",
    "thumbnail": "",
    "location": {
      "geoLocation": {
        "lng": 51.56185809999999,
        "lat": 32.8669179
      },
      "address": "VH86+QPQ, Shahin Shahr, Isfahan Province, Iran",
      "city": "Shahin Shahr",
      "state": "Isfahan Province",
      "country": "Iran"
    },
    "reviewCount": 1,
    "scores": {
      "overall": 5,
      "drinkQuality": 3,
      "foodQuality": 4,
      "atmosphere": 5,
      "service": 4,
      "value": null
    },
    "phone": null,
    "categories": [
      "restaurant"
    ]
  },
  "activityType": "NEW_REVIEW",
  "resourceType": "Review",
  "resource": {
    "_id": "64d2aa872c509f60b769037e",
    "scores": {
      "overall": 5,
      "drinkQuality": 3,
      "foodQuality": 4,
      "atmosphere": 5,
      "service": 4
    },
    "content": "Cute vibe \nCozy atmosphere \nDelicious pancakes \nCool music \nHighly recommended ",
    "images": [
      {
        "_id": "64d2aa872c509f60b7690379",
        "src": "https://phantom-localdev.s3.us-west-1.amazonaws.com/64d29e412c509f60b768f240/images/3666139990c19d686988b14d23f68754.jpg",
        "caption": null,
        "type": "image"
      }
    ],
    "videos": [
      {
        "_id": "64d2aa782c509f60b7690376",
        "src": "https://phantom-localdev.s3.us-west-1.amazonaws.com/64d29e412c509f60b768f240/videos/e730e628c2f3354e4157c6aa6cee2dfb.mp4",
        "caption": null,
        "type": "video"
      }
    ],
    "tags": [
      "cozy_atmosphere",
      "trendy_spot",
      "brunch_spot"
    ],
    "createdAt": "2023-08-08T20:50:15.905Z",
    "updatedAt": "2023-08-08T20:50:17.297Z",
    "userActivityId": "64d2aa872c509f60b7690386",
    "place": {
      "_id": "64d2a0c62c509f60b768f572",
      "name": "Lavender",
      "otherNames": [],
      "description": "",
      "thumbnail": "",
      "location": {
        "geoLocation": {
          "lng": 51.56185809999999,
          "lat": 32.8669179
        },
        "address": "VH86+QPQ, Shahin Shahr, Isfahan Province, Iran",
        "city": "Shahin Shahr",
        "state": "Isfahan Province",
        "country": "Iran"
      },
      "reviewCount": 1,
      "scores": {
        "overall": 5,
        "drinkQuality": 3,
        "foodQuality": 4,
        "atmosphere": 5,
        "service": 4,
        "value": null
      },
      "phone": null,
      "categories": [
        "restaurant"
      ]
    },
    "writer": {
      "_id": "64d29e412c509f60b768f240",
      "name": "Soli",
      "username": "solimkr2001",
      "bio": "PharmD stu\nInfluencer \nAlways on a diet",
      "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/64d29e412c509f60b768f240/profile.jpg",
      "xp": 57,
      "level": 1,
      "verified": true,
      "coins": 9
    },
    "reactions": {
      "total": [
        {
          "count": 1,
          "type": "emoji",
          "reaction": "🥰"
        },
        {
          "count": 1,
          "type": "emoji",
          "reaction": "❤️"
        },
        {
          "count": 1,
          "type": "emoji",
          "reaction": "👍"
        }
      ]
    }
  },
  "privacyType": "PUBLIC",
  "createdAt": "2023-08-08T20:50:15.916Z",
  "updatedAt": "2023-08-08T20:50:15.916Z",
  "score": 574.8699489214853,
  "weight": 1,
  "reactions": {
    "total": [
      {
        "count": 1,
        "type": "emoji",
        "reaction": "👍"
      },
      {
        "count": 1,
        "type": "emoji",
        "reaction": "❤️"
      },
      {
        "count": 1,
        "type": "emoji",
        "reaction": "🥰"
      }
    ],
    "user": [
      {
        "_id": "64d35ef61eff94afe959dd9e",
        "type": "emoji",
        "reaction": "❤️",
        "createdAt": "2023-08-09T09:40:06.866Z"
      }
    ]
  },
  "comments": [
    {
      "_id": "64d4ee982c9a8ed008970ec3",
      "content": "Hey @nabeel check this out",
      "createdAt": "2023-08-10T14:05:12.743Z",
      "updatedAt": "2023-08-10T14:05:12.743Z",
      "author": {
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
      "likes": 0,
      "liked": false
    }
  ]
}
"""

fileprivate let dummyFeedItem = decodeFeedItem(from: dummyJSON)

#Preview {
    ScrollView {
        if let d = dummyFeedItem {
            FeedReviewView(data: d)
        }
    }
}
