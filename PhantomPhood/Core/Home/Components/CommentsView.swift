//
//  CommentsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 25.09.2023.
//

import SwiftUI

struct CommentsView: View {
    @Binding var commentsLoading: Bool
    @Binding var comments: [Comment]
    @Binding var commentContent: String
    var FeedItemId: String
    var getComments: () async -> ()
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 30, height: 3)
                .foregroundStyle(.tertiary)
            Text("Comments")
                .font(.custom(style: .subheadline))
                .fontWeight(.bold)
                .padding(.top, 5)
            Divider()
            
            ScrollView {
                if commentsLoading {
                    ProgressView()
                } else {
                    if comments.isEmpty {
                        VStack {
                            Text("No Comments yet")
                                .font(.title2)

                            Text("Start the conversation")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 50)
                    }
                }
                ForEach(comments) { comment in
                    VStack {
                        HStack {
                            NavigationLink(value: HomeStack.userProfile(id: comment.author.id)) {
                                if let profileImage = comment.author.profileImage, let url = URL(string: profileImage) {
                                    AsyncImage(url: url) { phase in
                                        Group {
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 44, height: 44)
                                                    .clipShape(Circle())
                                            } else if phase.error != nil {
                                                Circle()
                                                    .frame(width: 44, height: 44)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        Image(systemName: "exclamationmark.icloud")
                                                    }
                                            } else {
                                                Circle()
                                                    .frame(width: 44, height: 44)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            }
                                        }
                                        .overlay(alignment: .top) {
                                            LevelView(level: .convert(level: comment.author.level))
                                                .frame(width: 36, height: 36)
                                                .offset(y: 28)
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .overlay(alignment: .top) {
                                            LevelView(level: .convert(level: comment.author.level))
                                                .frame(width: 36, height: 36)
                                                .offset(y: 28)
                                        }
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(comment.author.name)
                                            .font(.custom(style: .body))
                                            .bold()
                                            .foregroundStyle(.primary)
                                        Text(DateFormatter.getPassedTime(from: comment.createdAt))
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)

                                    Text(comment.content)
                                        .font(.custom(style: .body))
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Image(systemName: "heart")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Divider()
                            .padding(.top)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            Divider()
            
            TextField("Add a comment", text: $commentContent, axis: .vertical)
                .lineLimit(1...4)
                .padding(.all, 8)
                .padding(.trailing, 35)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themePrimary)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        
                    } label: {
                        Text("Post")
                    }
                    .padding(.all, 9)
                }.padding(.horizontal)
                .padding(.vertical, 5)
            
        }
        .padding(.top)
        .onAppear {
            Task {
                if comments.isEmpty {
                    await getComments()
                }
            }
        }
        
    }
}

#Preview {
    CommentsView(commentsLoading: .constant(false), comments: .constant([]), commentContent: .constant(""), FeedItemId: "TEST_FEED_ITEM_ID") {
        print("Get Comments")
    }
}
