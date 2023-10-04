//
//  FeedReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 25.09.2023.
//

import SwiftUI

struct FeedReviewView: View {
    let data: FeedItem
    @State var showComments = false
    @State var showMedia = false
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments, isActive: showMedia || showComments) {
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
                    Text("Reviewed")
                        .font(.custom(style: .caption))
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color("Reviewed"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                    if let place = data.place {
                        Text(place.name)
                            .font(.custom(style: .body))
                            .fontWeight(.bold)
                    }
                }
            }.padding(.bottom)
        } content: {
                switch data.resource {
                case .review(let review):
                    VStack {
                        if !review.images.isEmpty || !review.videos.isEmpty {
                            ZStack {
                                GeometryReader(content: { geometry in
                                    TabView {
                                        if !review.videos.isEmpty {
                                            ForEach(review.videos) { video in
                                                ReviewVideoView(url: video.src, mute: true)
                                                    .frame(height: 300)
                                                    .frame(maxWidth: UIScreen.main.bounds.width)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(alignment: .topTrailing) {
                                                        Image(systemName: "video")
                                                            .padding(.top, 8)
                                                            .padding(.trailing, 5)
                                                    }
                                            }
                                        }
                                        if !review.images.isEmpty {
                                            ForEach(review.images) { image in
                                                if let url = URL(string: image.src) {
                                                    AsyncImageLoader(url)
                                                        .frame(height: 300)
                                                        .frame(maxWidth: UIScreen.main.bounds.width)
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(alignment: .topTrailing) {
                                                            Image(systemName: "photo")
                                                                .padding(.top, 8)
                                                                .padding(.trailing, 5)
                                                        }
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(.page)
                                })
                            }
                            .onTapGesture {
                                showMedia = true
                            }
                            .frame(minHeight: 300)
                        }
                        
                        Text(review.content)
                            .font(.custom(style: .body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                    }
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
            
//            if showComments {
//                Text("Show Comments")
//            }
//            if showMedia {
//                Text("Show Media")
//            }
        }
        .sheet(isPresented: $showComments, content: {
            CommentsView(activityId: data.id)
        })
        .fullScreenCover(isPresented: $showMedia, content: {
            MediaView(showMedia: $showMedia, resource: data.resource)
        })
    }
}

fileprivate struct MediaView: View {
    @Binding var showMedia: Bool
    let resource: FeedItemResource
    @State var offset: CGSize = .zero
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showMedia = false
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding()
            
            Spacer()
            
            if showMedia {
                switch resource {
                case .review(let review):
                    VStack {
                        if !review.images.isEmpty || !review.videos.isEmpty {
                            TabView {
                                if !review.videos.isEmpty {
                                    ForEach(review.videos) { video in
                                        ReviewVideoView(url: video.src)
                                            .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                    }
                                }
                                if !review.images.isEmpty {
                                    ForEach(review.images) { image in
                                        if let url = URL(string: image.src) {
                                            AsyncImageLoader(url)
                                                .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                        }
                    }
                    .frame(maxHeight: .infinity)
                default:
                    EmptyView()
                }
                
            }
        }
        
    }
}

#Preview {
    let dummyJSON = """
    {
      "id": "64d2aa872c509f60b7690386",
      "user": {
        "_id": "64d29e412c509f60b768f240",
        "name": "Kia",
        "username": "TheKia",
        "bio": "Test",
        "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
        "xp": 57,
        "level": 3,
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
        "categories": ["restaurant"]
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
        "content": "Cute vibe \\nCozy atmosphere \\nDelicious pancakes \\nCool music \\nHighly recommended ",
        "images": [
          {
            "_id": "64d2aa872c509f60b7690379",
            "src": "https://phantom-localdev.s3.us-west-1.amazonaws.com/64b5a0bad66d45323e935bda/images/5e4bb644c11875b8a929b650ead98af7.jpg",
            "caption": null,
            "type": "image"
          }
        ],
        "videos": [
          {
            "_id": "64d2aa782c509f60b7690376",
            "src": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/2a667b01b413fd08fd00a60b2f5ba3e1.mp4",
            "caption": null,
            "type": "video"
          }
        ],
        "tags": ["cozy_atmosphere", "trendy_spot", "brunch_spot"],
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
          "categories": ["restaurant"]
        },
        "writer": {
          "_id": "64d29e412c509f60b768f240",
          "name": "Soli",
          "username": "solimkr2001",
          "bio": "PharmD stu\\nInfluencer \\nAlways on a diet",
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

    let dummyFeedItem = decodeFeedItem(from: dummyJSON)
    
    return ScrollView {
        if let d = dummyFeedItem {
            FeedReviewView(data: d)
        }
    }
    .padding(.horizontal)
}
