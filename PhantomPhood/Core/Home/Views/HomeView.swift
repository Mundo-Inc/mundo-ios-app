//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: Authentication
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject var searchViewModel = SearchViewModel()
    
    @State var showActions: Bool = false
    
    @State var reportId: String? = nil
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $appData.homeActiveTab) {
                    ForYouView()
                        .tag(HomeTab.forYou)
                    
                    FeedView(reportId: $reportId)
                        .tag(HomeTab.followings)
                }
                .ignoresSafeArea()
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(Color.themeBG)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: HomeStack.notifications) {
                            Image(systemName: "bell")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    appData.homeActiveTab = .forYou
                                }
                            } label: {
                                Text(HomeTab.forYou.rawValue)
                                    .overlay(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .foregroundStyle(.secondary)
                                            .frame(height: 3)
                                            .frame(maxWidth: appData.homeActiveTab != .forYou ? 0 : .infinity)
                                            .offset(y: 5)
                                            .animation(appData.homeActiveTab != .forYou ? .easeOut : .bouncy, value: appData.homeActiveTab)
                                    }
                            }
                            
                            Button {
                                withAnimation {
                                    appData.homeActiveTab = .followings
                                }
                            } label: {
                                Text(HomeTab.followings.rawValue)
                                    .overlay(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .foregroundStyle(.secondary)
                                            .frame(height: 3)
                                            .frame(maxWidth: appData.homeActiveTab != .followings ? 0 : .infinity)
                                            .offset(y: 5)
                                            .animation(appData.homeActiveTab != .followings ? .easeOut : .bouncy, value: appData.homeActiveTab)
                                    }
                            }
                        }
                        .font(.custom(style: .headline))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .automatic)
                .navigationBarTitleDisplayMode(.inline)
                
                Button {
                    showActions = true
                } label: {
                    Circle()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                        .rotationEffect(showActions ? .degrees(135) : .zero)
                        .scaleEffect(showActions ? 2 : 1)
                        .opacity(showActions ? 0 : 1)
                        .offset(y: showActions ? 50 : 0)
                        .animation(.bouncy, value: showActions)
                        .padding(.trailing)
                        .padding(.bottom)
                }
                
                if reportId != nil {
                    ReportView(id: $reportId, type: .review)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: reportId)
                }
                
            }
            .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
                searchViewModel.tokens.removeAll()
                searchViewModel.text = ""
            }) {
                SearchView(vm: searchViewModel) { place in
                    if let title = place.name {
                        appData.homeNavStack.append(HomeStack.placeMapPlace(mapPlace: MapPlace(coordinate: place.placemark.coordinate, title: title), action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                    }
                } onUserSelect: { user in
                    appData.homeNavStack.append(HomeStack.userProfile(id: user.id))
                }
            }
            .navigationDestination(for: HomeStack.self) { link in
                switch link {
                case .notifications:
                    NotificationsView()
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .placeMapPlace(let mapPlace, let action):
                    PlaceView(mapPlace: mapPlace, action: action)
                case .userProfile(let id):
                    UserProfileView(id: id)
                case .userConnections(let userId, let initTab):
                    UserConnectionsView(userId: userId, activeTab: initTab)
                }
            }
        }
        .environmentObject(searchViewModel)
        .sheet(isPresented: $showActions) {
            VStack {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 30, height: 3)
                    .padding(.top)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Button {
                    showActions = false
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.checkin]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        searchViewModel.showSearch = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.diamond")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Check-in")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Check in to places that you go!")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Button {
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.addReview]
                    showActions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        searchViewModel.showSearch = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 32))
                        
                        VStack {
                            Text("Review")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Add a review to a place that you’ve been")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .presentationDetents([.height(250)])
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppData())
            .environmentObject(Authentication())
            .environmentObject(LocationManager())
    }
}
