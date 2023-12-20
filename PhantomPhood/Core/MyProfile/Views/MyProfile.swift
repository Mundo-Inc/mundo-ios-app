//
//  MyProfile.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI

struct MyProfile: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    var body: some View {
        NavigationStack(path: $appData.myProfileNavStack) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        HStack(spacing: 12) {
                            ProfileImage(auth.currentUser?.profileImage, size: 82, cornerRadius: 15)
                            
                            VStack {
                                if (auth.currentUser != nil && auth.currentUser!.verified) {
                                    HStack {
                                        Text(auth.currentUser?.name ?? "User Name")
                                            .font(.custom(style: .title2))
                                            .bold()
                                        Image(systemName: "checkmark.seal")
                                            .foregroundStyle(.blue)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                } else {
                                    Text(auth.currentUser?.name ?? "User Name")
                                        .font(.custom(style: .title2))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Text("@\(auth.currentUser?.username ?? "testUsername")")
                                    .font(.custom(style: .footnote))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    appData.showEditProfile.toggle()
                                } label: {
                                    Text("Edit Profile")
                                        .font(.custom(style: .footnote))
                                        .frame(maxWidth: .infinity)
                                    
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .controlSize(.small)
                            }
                            .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        if let bio = auth.currentUser?.bio, !bio.isEmpty {
                            Text(bio)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .footnote))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                        
                        ScrollView(.horizontal) {
                            HStack {
                                Color.clear
                                    .frame(width: 0)
                                    .padding(.leading)
                                
                                ForEach(MyProfileActiveTab.allCases.indices, id: \.self) { i in
                                    Button {
                                        withAnimation {
                                            appData.myProfileActiveTab = MyProfileActiveTab.allCases[i]
                                        }
                                    } label: {
                                        Text(MyProfileActiveTab.allCases[i].rawValue)
                                            .font(.custom(style: .footnote))
                                            .bold()
                                            .textCase(.uppercase)
                                            .padding(.vertical, 5)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .foregroundStyle(
                                        appData.myProfileActiveTab == MyProfileActiveTab.allCases[i] ? Color.accentColor : Color.secondary
                                    )
                                    .padding(i == 0 ? .trailing : i == MyProfileActiveTab.allCases.count - 1 ? .leading : .horizontal)
                                    
                                    if i != MyProfileActiveTab.allCases.count - 1 {
                                        Divider()
                                    }
                                }
                                
                                Color.clear
                                    .frame(width: 0)
                                    .padding(.trailing)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.themePrimary
                            .clipShape(
                                .rect(
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 20
                                )
                            )
                    }
                    .id(1)
                    
                    
                    VStack {
                        Group {
                            switch appData.myProfileActiveTab {
                            case .stats:
                                ProfileStats()
                            case .achievements:
                                ProfileAchievements()
                            case .activity:
                                ProfileActivity()
                            case .checkins:
                                ProfileCheckins()
                            }
                        }
                    }
                    .frame(minHeight: UIScreen.main.bounds.height / 1.5)
                    .background(
                        Color.themeBG
                            .offset(y: -30)
                    )
                    .zIndex(-1)
                }
                .scrollIndicators(.hidden)
                .fullScreenCover(isPresented: $appData.showEditProfile, content: {
                    EditProfileView()
                })
                .refreshable {
                    await auth.updateUserInfo()
                }
                .frame(maxHeight: .infinity)
                .background(
                    VStack {
                        Color.themePrimary.ignoresSafeArea()
                        Color.themeBG.ignoresSafeArea()
                    }
                        .frame(maxHeight: .infinity)
                )
                .navigationTitle("My Profile")
                .toolbar {
                    HStack {
                        NavigationLink(value: MyProfileStack.settings) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: MyProfileStack.self) { link in
                    switch link {
                    case .settings:
                        SettingsView()
                    case .place(let id, let action):
                        PlaceView(id: id, action: action)
                    case .userProfile(let id):
                        UserProfileView(id: id)
                    case .myConnections(let initTab):
                        MyConnections(activeTab: initTab)
                    case .userConnections(let userId, let initTab):
                        UserConnectionsView(userId: userId, activeTab: initTab)
                    }
                }
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .myProfile {
                        withAnimation {
                            proxy.scrollTo(1)
                        }
                        appData.tappedTwice = nil
                    }
                }
            }
        }
    }
}

#Preview {
    MyProfile()
}
