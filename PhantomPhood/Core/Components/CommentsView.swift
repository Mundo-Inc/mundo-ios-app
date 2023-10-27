//
//  CommentsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/4/23.
//

import SwiftUI

struct CommentsView: View {
    @ObservedObject var vm: CommentsViewModel
        
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
                if vm.isLoading {
                    ProgressView()
                } else {
                    if vm.comments.isEmpty {
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
                ForEach(vm.comments) { comment in
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
                                            LevelView(level: comment.author.progress.level)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 30)
                                                .offset(y: 28)
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .overlay(alignment: .top) {
                                            LevelView(level: comment.author.progress.level)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 30)
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
            // TODO: - here
//            .refreshable {
//                await vm.getComments()
//            }
            
            Spacer()
            
            Divider()
            
            TextField("Add a comment", text: $vm.commentContent, axis: .vertical)
                .lineLimit(1...4)
                .padding(.all, 8)
                .padding(.trailing, 35)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.themePrimary)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        Task {
                            await vm.submitComment()
                        }
                    } label: {
                        Text("Post")
                    }
                    .opacity(vm.isSubmitting ? 0.6 : 1)
                    .disabled(vm.isSubmitting)
                    .padding(.all, 9)
                }.padding(.horizontal)
                .padding(.vertical, 5)
            
        }
        .padding(.top)
    }
}

#Preview {
    CommentsView(vm: CommentsViewModel())
}
