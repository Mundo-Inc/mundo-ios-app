//
//  FeedItemTemplate.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

// TODO: Add View Model

// MARK: - Line Arch
fileprivate struct LineArchShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.width))
            path.addArc(
                center: CGPoint(x: rect.maxX, y: rect.maxY - rect.width),
                radius: rect.width,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 90),
                clockwise: true
            )
        }
    }
}

fileprivate struct LineArchView: View {
    var body: some View {
        LineArchShape()
            .stroke(Color.themeBorder, lineWidth: 2)
    }
}

// MARK: - Comment View
fileprivate struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                    .frame(width: 2)
                    .overlay(alignment: .topLeading) {
                        LineArchView()
                            .frame(width: 22, height: 75)
                    }
                    .offset(x: 1, y: -50)
            }
            .zIndex(1)
            .frame(width: 44)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.author.name + ": ")
                        .bold() +
                    Text(comment.content)
                }
                .font(.custom(style: .footnote))
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct FeedItemTemplate<Header: View, Content: View, Footer: View>: View {
    let comments: [Comment]
    let header: () -> Header
    let content: () -> Content
    let footer: () -> Footer
    let user: User
    
    init(
        user: User,
        comments: [Comment] = [],
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.header = header
        self.content = content
        self.footer = footer
        self.comments = comments
        self.user = user
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                VStack {
                    NavigationLink(value: HomeStack.userProfile(id: user.id)) {
                        if let profileImage = user.profileImage, let url = URL(string: profileImage) {
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
                                    LevelView(level: .convert(level: user.level))
                                        .frame(width: 36, height: 36)
                                        .offset(y: 28)
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .overlay(alignment: .top) {
                                    LevelView(level: .convert(level: user.level))
                                        .frame(width: 36, height: 36)
                                        .offset(y: 28)
                                }
                        }
                    }
                    
                    
                    Spacer()
                }
                .frame(height: 64)
                
                VStack {
                    header()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .zIndex(1)
            
            HStack {
                VStack {
                    Spacer()
                        .frame(width: 2)
                        .background(Color.themeBorder)
                }
                .frame(width: 44)
                .frame(maxHeight: .infinity)
                
                VStack {
                    content()
                }
                .padding(.top, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            ForEach(comments) { comment in
                CommentView(comment: comment)
            }
                        
            HStack {
                VStack {}
                    .frame(width: 44)
                    .frame(maxHeight: .infinity)
                
                VStack {
                    footer()
                }
                .padding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.frame(maxWidth: .infinity)
    }
}

let dateFormatter = ISO8601DateFormatter()
#Preview {
    ScrollView {
        FeedItemTemplate(
            user: User(
                _id: "TEST_USER_ID",
                name: "Dwayne",
                username: "DwayneTheRock",
                bio: "This is test bio",
                coins: 40,
                xp: 2400,
                level: 7,
                verified: true,
                profileImage: "https://images.pexels.com/photos/3220360/pexels-photo-3220360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
            ),
            comments: [
                Comment(
                    _id: "TEST_COMMENT_ID_1",
                    content: "This is the comment body let's see what happens if this exceeds two lines",
                    createdAt: "2023-09-19T20:06:45.214Z",
                    updatedAt: "2023-09-19T20:06:45.214Z",
                    author: User(
                        _id: "TEST_USER_ID",
                        name: "Dwayne",
                        username: "DwayneTheRock",
                        bio: "This is test bio",
                        coins: 40,
                        xp: 2400,
                        level: 7,
                        verified: true,
                        profileImage: "https://images.pexels.com/photos/3220360/pexels-photo-3220360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
                    ),
                    likes: 4,
                    liked: true,
                    mentions: []
                )
            ]
        ) {
            Text("Header")
        } content: {
            Text("Content")
        }
    }
}
