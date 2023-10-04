//
//  FeedCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FeedCheckinView: View {
    let data: FeedItem
    @State var showComments = false
    
    var body: some View {
        FeedItemTemplate(user: data.user, comments: data.comments, isActive: showComments) {
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
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke()
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Image(systemName: "checkmark.rectangle.stack")
                                                .font(.system(size: 20))
                                        }
                                        .foregroundStyle(.green)
                                    
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
                                                    .font(.custom(style: .subheadline))
                                                    .bold()
                                                    .foregroundStyle(Color.accentColor)
                                            } else {
                                                Text("TBD")
                                            }
                                            
                                            if place.scores.phantom != nil && place.priceRange != nil {
                                                Text(".")
                                            }
                                            
                                            if let priceRange = place.priceRange {
                                                Text(String(repeating: "$", count: priceRange))
                                            }
                                        }
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
      "id": "6512c2bebc559c3adc946959",
      "user": {
        "_id": "645c8b222134643c020860a5",
        "name": "Kia Abdi",
        "username": "TheKia",
        "bio": "Passionate tech lover. foodie",
        "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
        "level": 3,
        "verified": true,
        "xp": 387,
        "coins": 81
      },
      "place": {
        "_id": "64e77dbb6dd58701d0714fff",
        "name": "Dozze Coffee & Bookstore",
        "otherNames": [],
        "description": "",
        "thumbnail": "https://phantom-localdev.s3.us-west-1.amazonaws.com/places/64e77dbb6dd58701d0714fff/thumbnail.jpg",
        "location": {
          "geoLocation": {
            "lng": 29.0756875,
            "lat": 41.0148645
          },
          "address": "Bulgurlu Mahallesi Libadiye Caddesi No: 17/ CB, Bulgurlu, 34345 Üsküdar/İstanbul, Türkiye",
          "city": "İstanbul",
          "state": "İstanbul",
          "country": "Türkiye",
          "zip": "34345"
        },
        "reviewCount": 6,
        "scores": {
          "overall": 4.4,
          "drinkQuality": 3.6666666666666665,
          "foodQuality": null,
          "atmosphere": 3.3333333333333335,
          "service": 3,
          "value": null,
          "phantom": 73.06666666666666,
          "_id": "64ea71a35a7173564e1fdcd9"
        },
        "phone": "+905307605069",
        "categories": [
          "cafe"
        ]
      },
      "activityType": "NEW_CHECKIN",
      "resourceType": "Checkin",
      "resource": {
        "totalCheckins": 10,
        "_id": "6512c2bebc559c3adc946950",
        "user": {
          "_id": "645c8b222134643c020860a5",
          "name": "Kia Abdi",
          "username": "TheKia",
          "bio": "Passionate tech lover. foodie",
          "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
          "level": 3,
          "verified": true,
          "xp": 387,
          "coins": 81
        },
        "place": {
          "_id": "64e77dbb6dd58701d0714fff",
          "name": "Dozze Coffee & Bookstore",
          "otherNames": [],
          "description": "",
          "thumbnail": "https://phantom-localdev.s3.us-west-1.amazonaws.com/places/64e77dbb6dd58701d0714fff/thumbnail.jpg",
          "location": {
            "geoLocation": {
              "lng": 29.0756875,
              "lat": 41.0148645
            },
            "address": "Bulgurlu Mahallesi Libadiye Caddesi No: 17/ CB, Bulgurlu, 34345 Üsküdar/İstanbul, Türkiye",
            "city": "İstanbul",
            "state": "İstanbul",
            "country": "Türkiye",
            "zip": "34345"
          },
          "reviewCount": 6,
          "scores": {
            "overall": 4.4,
            "drinkQuality": 3.6666666666666665,
            "foodQuality": null,
            "atmosphere": 3.3333333333333335,
            "service": 3,
            "value": null,
            "phantom": 73.06666666666666,
            "_id": "64ea71a35a7173564e1fdcd9"
          },
          "phone": "+905307605069",
          "categories": [
            "cafe"
          ]
        },
        "createdAt": "2023-09-26T11:38:38.979Z"
      },
      "privacyType": "PUBLIC",
      "createdAt": "2023-09-26T11:38:38.998Z",
      "updatedAt": "2023-09-26T11:38:38.998Z",
      "score": 28.923473164013107,
      "weight": 1,
      "reactions": {
        "total": [],
        "user": []
      },
      "comments": []
    }
    """

    let dummyFeedItem = decodeFeedItem(from: dummyJSON)
    
    return ScrollView {
        if let d = dummyFeedItem {
            FeedCheckinView(data: d)
        }
    }
    .padding(.horizontal)
}
