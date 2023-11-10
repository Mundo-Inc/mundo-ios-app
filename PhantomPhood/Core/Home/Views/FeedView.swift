//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI
import Kingfisher

struct FeedView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @StateObject var commentsViewModel = CommentsViewModel()
    @StateObject var mediasViewModel = MediasViewModel()
    @StateObject var vm = FeedViewModel()
    
    @Binding var reportId: String?
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
                .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
                    searchViewModel.tokens.removeAll()
                    searchViewModel.text = ""
                    dismissSearch()
                }) {
                    SearchView(vm: searchViewModel) { place in
                        if let title = place.name {
                            appData.homeNavStack.append(HomeStack.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                        }
                    } onUserSelect: { user in
                        appData.homeNavStack.append(HomeStack.userProfile(id: user.id))
                    }
                }
            ScrollView {
                if !vm.isLoading && vm.feedItems.isEmpty {
                    Text("Everyone starts somewhere! Why not with our rockstar CEO, Nabeel? 🎸")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom(style: .body))
                        .padding(.top)
                        .padding(.horizontal)
                        .onAppear {
                            if vm.nabeel == nil {
                                Task {
                                    await vm.getNabeel()
                                }
                            }
                        }
                    
                    HStack(spacing: 15) {
                        if let nabeel = vm.nabeel, !nabeel.profileImage.isEmpty, let imageURL = URL(string: nabeel.profileImage) {
                            KFImage.url(imageURL)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.tertiary)
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .fade(duration: 0.25)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .contentShape(Rectangle())
                                .clipShape(.rect(cornerRadius: 15))
                        } else {
                            // No Image
                            if vm.nabeel == nil {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 100, height: 100)
                                    .background(Color.themeBG)
                                    .clipShape(.rect(cornerRadius: 15))
                            }
                        }
                        
                        VStack {
                            VStack {
                                Text(vm.nabeel?.name ?? "Nabeel")
                                    .font(.custom(style: .title2))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("@\(vm.nabeel?.username ?? "Username")")
                                    .font(.custom(style: .headline))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Group {
                                if let isFollowing = vm.isFollowingNabeel {
                                    if !isFollowing {
                                        Button {
                                            Task {
                                                await vm.followNabeel()
                                            }
                                        } label: {
                                            Text(vm.isRequestingFollow ? "Requesting" : "Follow")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(BorderedProminentButtonStyle())
                                        .disabled(vm.isRequestingFollow)
                                    } else {
                                        Button {
                                            print("Unexpected")
                                        } label: {
                                            Text("Hmm, You already follow him!")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(BorderedProminentButtonStyle())
                                        .disabled(vm.isRequestingFollow)
                                    }
                                } else {
                                    Button {} label: {
                                        Text("Loading")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                    .disabled(vm.isRequestingFollow)
                                }
                            }
                            .font(.custom(style: .footnote))
                            .controlSize(.small)
                        }
                    }
                    .padding(.horizontal)
                    .redacted(reason: vm.nabeel == nil ? .placeholder : [])
                    
                } else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .sheet(isPresented: $commentsViewModel.showComments, content: {
                            CommentsView(vm: commentsViewModel)
                        })
                    Color.clear
                        .frame(width: 0, height: 0)
                        .fullScreenCover(isPresented: $mediasViewModel.show, content: {
                            MediasView(vm: mediasViewModel)
                        })

                    LazyVStack(spacing: 20) {
                        ForEach(vm.feedItems) { item in
                            Group {
                                switch item.activityType {
                                case .levelUp:
                                    FeedLevelUpView(data: item, commentsViewModel: commentsViewModel)
                                case .following:
                                    FeedFollowingView(data: item, commentsViewModel: commentsViewModel)
                                case .newReview:
                                    FeedReviewView(data: item, commentsViewModel: commentsViewModel, mediasViewModel: mediasViewModel, reportId: $reportId)
                                case .newCheckin:
                                    FeedCheckinView(data: item, commentsViewModel: commentsViewModel)
                                default:
                                    Text(item.activityType.rawValue)
                                }
                            }
                            .padding(.horizontal)
                            .onAppear {
                                if !vm.isLoading {
                                    Task {
                                        await vm.loadMore(currentItem: item)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Home")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
                                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: HomeStack.notifications) {
                        Image(systemName: "bell")
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                Task {
                    if !vm.isLoading {
                        await vm.getFeed(.refresh)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(reportId: .constant(nil))
            .environmentObject(AppData())
            .environmentObject(SearchViewModel())
    }
}
