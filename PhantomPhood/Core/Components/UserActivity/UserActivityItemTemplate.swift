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
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .cfont(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct UserActivityItemTemplate<Header: View, Content: View, Footer: View>: View {
    let comments: [Comment]
    let header: () -> Header
    let content: () -> Content
    let footer: () -> Footer
    let user: UserEssentials
    
    init(
        user: UserEssentials,
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
                    NavigationLink(value: AppRoute.userProfile(userId: user.id)) {
                        ProfileImage(user.profileImage, size: 44)
                            .overlay(alignment: .top) {
                                LevelView(level: user.progress.level)
                                    .frame(width: 24, height: 30)
                                    .offset(y: 28)
                                    .shadow(radius: 10)
                            }
                    }
                    .foregroundStyle(.secondary)
                    
                    
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
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        UserActivityItemTemplate(
            user: UserEssentials(
                id: "TEST_USER_ID",
                name: "Dwayne",
                username: "DwayneTheRock",
                verified: true,
                isPrivate: false,
                profileImage: nil,
                progress: .init(level: 7, xp: 300),
                connectionStatus: nil
            ),
            comments: [
                Comment(
                    id: "TEST_COMMENT_ID_1",
                    content: "This is the comment body let's see what happens if this exceeds two lines",
                    createdAt: .now,
                    updatedAt: .now,
                    author: UserEssentials(
                        id: "TEST_USER_ID",
                        name: "Dwayne",
                        username: "DwayneTheRock",
                        verified: true,
                        isPrivate: false,
                        profileImage: URL(string: "https://images.pexels.com/photos/3220360/pexels-photo-3220360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                        progress: .init(level: 7, xp: 300),
                        connectionStatus: nil
                    ),
                    mentions: [],
                    likes: 4,
                    liked: true
                )
            ]
        ) {
            Text("Header")
        } content: {
            Text("Content")
        }
        
        UserActivityItemTemplate(
            user: UserEssentials(
                id: "TEST_USER_ID",
                name: "Dwayne",
                username: "DwayneTheRock",
                verified: true,
                isPrivate: false,
                profileImage: URL(string: "https://images.pexels.com/photos/3220360/pexels-photo-3220360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                progress: .init(level: 52, xp: 3000),
                connectionStatus: nil
            ),
            comments: [
                Comment(
                    id: "TEST_COMMENT_ID_1",
                    content: "This is the comment body let's see what happens if this exceeds two lines",
                    createdAt: .now,
                    updatedAt: .now,
                    author: UserEssentials(
                        id: "TEST_USER_ID",
                        name: "Dwayne",
                        username: "DwayneTheRock",
                        verified: true,
                        isPrivate: false,
                        profileImage: URL(string: "https://images.pexels.com/photos/3220360/pexels-photo-3220360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                        progress: .init(level: 80, xp: 10000),
                        connectionStatus: nil
                    ),
                    mentions: [],
                    likes: 4,
                    liked: true
                )
            ]
        ) {
            Text("Header")
        } content: {
            Text("Content")
        }
    }
}
