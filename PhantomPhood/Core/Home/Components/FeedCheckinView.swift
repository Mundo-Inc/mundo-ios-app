//
//  FeedCheckinView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FeedCheckinView: View {
    let data: FeedItem
    @ObservedObject var commentsViewModel: CommentsViewModel
    
    @StateObject var selectReactionsViewModel = SelectReactionsViewModel.shared
    
    @StateObject var reactionsViewModel: ReactionsViewModel
    @State var reactions: ReactionsObject
    
    init(data: FeedItem, commentsViewModel: CommentsViewModel) {
        self.data = data
        self.commentsViewModel = commentsViewModel
        self._reactionsViewModel = StateObject(wrappedValue: ReactionsViewModel(activityId: data.id))
        self._reactions = State(wrappedValue: data.reactions)
    }
    
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
                                            } else {
                                                Text("TBD")
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            if place.scores.phantom != nil && place.priceRange != nil {
                                                Text(".")
                                            }
                                            
                                            if let priceRange = place.priceRange {
                                                Text(String(repeating: "$", count: priceRange))
                                            }
                                        }
                                        .font(.custom(style: .subheadline))
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
//      "id": "6512c2bebc559c3adc946959",
//      "user": {
//        "_id": "645c8b222134643c020860a5",
//        "name": "Kia Abdi",
//        "username": "TheKia",
//        "bio": "Passionate tech lover. foodie",
//        "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
//        "level": 3,
//        "verified": true,
//        "xp": 387,
//        "coins": 81
//      },
//      "place": {
//        "_id": "64e77dbb6dd58701d0714fff",
//        "name": "Dozze Coffee & Bookstore",
//        "otherNames": [],
//        "description": "",
//        "thumbnail": "https://phantom-localdev.s3.us-west-1.amazonaws.com/places/64e77dbb6dd58701d0714fff/thumbnail.jpg",
//        "location": {
//          "geoLocation": {
//            "lng": 29.0756875,
//            "lat": 41.0148645
//          },
//          "address": "Bulgurlu Mahallesi Libadiye Caddesi No: 17/ CB, Bulgurlu, 34345 Üsküdar/İstanbul, Türkiye",
//          "city": "İstanbul",
//          "state": "İstanbul",
//          "country": "Türkiye",
//          "zip": "34345"
//        },
//        "reviewCount": 6,
//        "scores": {
//          "overall": 4.4,
//          "drinkQuality": 3.6666666666666665,
//          "foodQuality": null,
//          "atmosphere": 3.3333333333333335,
//          "service": 3,
//          "value": null,
//          "phantom": 73.06666666666666,
//          "_id": "64ea71a35a7173564e1fdcd9"
//        },
//        "phone": "+905307605069",
//        "categories": [
//          "cafe"
//        ]
//      },
//      "activityType": "NEW_CHECKIN",
//      "resourceType": "Checkin",
//      "resource": {
//        "totalCheckins": 10,
//        "_id": "6512c2bebc559c3adc946950",
//        "user": {
//          "_id": "645c8b222134643c020860a5",
//          "name": "Kia Abdi",
//          "username": "TheKia",
//          "bio": "Passionate tech lover. foodie",
//          "profileImage": "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg",
//          "level": 3,
//          "verified": true,
//          "xp": 387,
//          "coins": 81
//        },
//        "place": {
//          "_id": "64e77dbb6dd58701d0714fff",
//          "name": "Dozze Coffee & Bookstore",
//          "otherNames": [],
//          "description": "",
//          "thumbnail": "https://phantom-localdev.s3.us-west-1.amazonaws.com/places/64e77dbb6dd58701d0714fff/thumbnail.jpg",
//          "location": {
//            "geoLocation": {
//              "lng": 29.0756875,
//              "lat": 41.0148645
//            },
//            "address": "Bulgurlu Mahallesi Libadiye Caddesi No: 17/ CB, Bulgurlu, 34345 Üsküdar/İstanbul, Türkiye",
//            "city": "İstanbul",
//            "state": "İstanbul",
//            "country": "Türkiye",
//            "zip": "34345"
//          },
//          "reviewCount": 6,
//          "scores": {
//            "overall": 4.4,
//            "drinkQuality": 3.6666666666666665,
//            "foodQuality": null,
//            "atmosphere": 3.3333333333333335,
//            "service": 3,
//            "value": null,
//            "phantom": 73.06666666666666,
//            "_id": "64ea71a35a7173564e1fdcd9"
//          },
//          "phone": "+905307605069",
//          "categories": [
//            "cafe"
//          ]
//        },
//        "createdAt": "2023-09-26T11:38:38.979Z"
//      },
//      "privacyType": "PUBLIC",
//      "createdAt": "2023-09-26T11:38:38.998Z",
//      "updatedAt": "2023-09-26T11:38:38.998Z",
//      "score": 28.923473164013107,
//      "weight": 1,
//      "reactions": {
//        "total": [
//            {
//                "count": 1,
//                "type": "emoji",
//                "reaction": "🎉"
//            },
//            {
//                "count": 2,
//                "type": "emoji",
//                "reaction": "😍"
//            },
//            {
//                "count": 1,
//                "type": "emoji",
//                "reaction": "🎉"
//            },
//            {
//                "count": 2,
//                "type": "emoji",
//                "reaction": "😍"
//            },
//            {
//                "count": 1,
//                "type": "emoji",
//                "reaction": "🎉"
//            },
//            {
//                "count": 2,
//                "type": "emoji",
//                "reaction": "😍"
//            }
//        ],
//        "user": [{
//            "_id": "650e17549baae711358b5adb",
//            "type": "emoji",
//            "reaction": "🎉",
//            "createdAt": "2023-09-22T22:38:12.237Z"
//          }]
//      },
//      "comments": []
//    }
//    """
//
//    let dummyFeedItem = decodeFeedItem(from: dummyJSON)
//    
//    return ScrollView {
//        if let d = dummyFeedItem {
//            FeedCheckinView(data: d, commentsViewModel: CommentsViewModel())
//        }
//    }
//    .environmentObject(SelectReactionsViewModel())
//    .padding(.horizontal)
//}
