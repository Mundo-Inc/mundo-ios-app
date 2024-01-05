//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    
//    @StateObject private var searchViewModel = SearchViewModel()
//    @State private var showActions: Bool = false
    @State private var reportId: String? = nil
    
    /// Used for pull to referesh - Percentage
    @State private var draggedAmount: Double = .zero
    private let dragAmountToRefresh: Double = 200.0
    
    // -
    @StateObject private var mediasViewModel = MediasViewModel()
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $appData.homeActiveTab) {
                    ForYouView(draggedAmount: $draggedAmount, dragAmountToRefresh: dragAmountToRefresh)
                        .tag(HomeTab.forYou)
                    
                    FeedView(mediasViewModel: mediasViewModel, reportId: $reportId)
                        .tag(HomeTab.followings)
                }
                .ignoresSafeArea()
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(Color.themeBG)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: AppRoute.notifications) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .frame(width: 44, height: 44)
                                .background(Circle().foregroundStyle(.black))
                                .overlay(alignment: .topTrailing) {
                                    if let unreadCount = notificationsVM.unreadCount, unreadCount > 0 {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.accentColor)
                                            .frame(minWidth: 16)
                                            .frame(maxWidth: 26, maxHeight: 16)
                                            .overlay {
                                                Text(unreadCount > 99 ? "99+" : "\(unreadCount)")
                                                    .font(.custom(style: .caption2))
                                                    .foregroundStyle(Color.white)
                                            }
                                    }
                                }
                                .onAppear {
                                    Task {
                                        await notificationsVM.updateUnreadNotificationsCount()
                                    }
                                }
                        }
                        .foregroundStyle(.white)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 0) {
                            ZStack {
                                if appData.homeActiveTab == .forYou {
                                    Capsule()
                                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                                        .foregroundStyle(Color.accentColor)
                                }

                                Button {
                                    withAnimation {
                                        appData.homeActiveTab = .forYou
                                    }
                                } label: {
                                    Text(HomeTab.forYou.rawValue)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            ZStack {
                                if appData.homeActiveTab == .followings {
                                    Capsule()
                                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                                        .foregroundStyle(Color.accentColor)
                                }
                                
                                Button {
                                    withAnimation {
                                        appData.homeActiveTab = .followings
                                    }
                                } label: {
                                    Text(HomeTab.followings.rawValue)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: 200, height: 32)
                        .background(Capsule().foregroundStyle(.black))
                        .font(.custom(style: .headline))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .opacity(1.0 - min(draggedAmount * 2, 1))
                        .offset(y: draggedAmount * 20)
                        .background {
                            HStack {
                                Text("Drag down to referesh")
                                Image(systemName: "menubar.arrow.down.rectangle")
                            }
                            .font(.custom(style: .caption))
                            .opacity(draggedAmount <= 1/3 ? 0 : abs((draggedAmount - 1/3) * 3/2))
                        }
                        .offset(y: draggedAmount * 20)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .automatic)
                .navigationBarTitleDisplayMode(.inline)
                
                if reportId != nil {
                    ReportView(id: $reportId, type: .review)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: reportId)
                }
            }
//            .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
//                searchViewModel.tokens.removeAll()
//                searchViewModel.text = ""
//            }) {
//                SearchView(vm: searchViewModel) { place in
//                    if let title = place.name {
//                        appData.homeNavStack.append(AppRoute.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
//                    }
//                } onUserSelect: { user in
//                    appData.homeNavStack.append(AppRoute.userProfile(userId: user.id))
//                }
//            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .notifications:
                    NotificationsView()
                case .userActivity(let id):
                    UserActivityView(id: id)
                    
                    // Place
                    
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .placeMapPlace(let mapPlace, let action):
                    PlaceView(mapPlace: mapPlace, action: action)
                    
                    // My Profile
                    
                case .settings:
                    SettingsView()
                case .myConnections(let initTab):
                    MyConnections(activeTab: initTab)
                    
                    // User
                    
                case .userProfile(let id):
                    UserProfileView(id: id)
                case .userConnections(let userId, let initTab):
                    UserConnectionsView(userId: userId, activeTab: initTab)
                case .userActivities(let userId, let activityType):
                    ProfileActivitiesView(userId: userId, activityType: activityType)
                case .userCheckins(let userId):
                    ProfileCheckins(userId: userId)
                    
                case .placesList(let listId):
                    PlacesListView(listId: listId)
                }
            }
        }
//        .environmentObject(searchViewModel)
//        .sheet(isPresented: $showActions) {
//            VStack {
//                RoundedRectangle(cornerRadius: 3)
//                    .frame(width: 30, height: 3)
//                    .padding(.top)
//                    .foregroundStyle(.tertiary)
//                
//                Spacer()
//                
//                Button {
//                    showActions = false
//                    searchViewModel.scope = .places
//                    searchViewModel.tokens = [.checkin]
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        searchViewModel.showSearch = true
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "checkmark.diamond")
//                            .font(.system(size: 32))
//                        
//                        VStack {
//                            Text("Check-in")
//                                .font(.custom(style: .headline))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("Check in to places that you go!")
//                                .multilineTextAlignment(.leading)
//                                .font(.custom(style: .caption))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                    .padding()
//                    .background(Color.themePrimary)
//                    .clipShape(.rect(cornerRadius: 15))
//                }
//                .foregroundStyle(.primary)
//                
//                Button {
//                    searchViewModel.scope = .places
//                    searchViewModel.tokens = [.addReview]
//                    showActions = false
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        searchViewModel.showSearch = true
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "star.bubble")
//                            .font(.system(size: 32))
//                        
//                        VStack {
//                            Text("Review")
//                                .font(.custom(style: .headline))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("Add a review to a place that you’ve been")
//                                .font(.custom(style: .caption))
//                                .multilineTextAlignment(.leading)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                    .padding()
//                    .background(Color.themePrimary)
//                    .clipShape(.rect(cornerRadius: 15))
//                }
//                .foregroundStyle(.primary)
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//            .presentationDetents([.height(250)])
//        }
    }
}

#Preview {
    HomeView()
}
