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
                FeedView(reportId: $reportId)
                
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
            .navigationDestination(for: HomeStack.self) { link in
                switch link {
                case .notifications:
                    NotificationsView()
                case .place(let id, let action):
                    PlaceView(id: id, action: action)
                case .userProfile(let id):
                    UserProfileView(id: id)
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
//        .searchable(text: $searchText) {
//            Label("Restaurants", systemImage: "fork.knife")
//                .searchCompletion("restaurant")
//            Label("Bars", systemImage: "wineglass")
//                .searchCompletion("restaurant")
//            Label("Cafe", systemImage: "cup.and.saucer.fill")
//                .searchCompletion("restaurant")
//        }
//        .searchable(text: $searchText, tokens: $tokens, suggestedTokens: $suggestedTokens, token: { token in
//            switch token {
//            case .restaurant: Text("Restaurant")
//            case .bar: Text("Bar")
//            case .cafe: Text("Cafe")
//            }
//        })
//        .onChange(of: searchScopes, {
//            print("Changed to \(searchScopes)")
//        })
//        .onChange(of: searchScopes, perform: { value in
//            tokens.removeAll()
//            if value == "Places" {
//                suggestedTokens = [.bar]
//            } else {
//                suggestedTokens = [.cafe, .restaurant]
//            }
//        })
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
