//
//  MyProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI

struct MyProfileView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    var body: some View {
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
                        }
                        .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button {
                            appData.showEditProfile.toggle()
                        } label: {
                            Text("Edit profile")
                                .frame(height: 32)
                                .frame(maxWidth: .infinity)
                                .background(Color.themeBorder)
                                .clipShape(.rect(cornerRadius: 5))
                                .foregroundStyle(Color.primary)
                        }
                        
                        if let currentUser = auth.currentUser, let url = URL(string: "https://phantomphood.ai/user/@\(currentUser.username)") {
                            ShareLink(item: url, message: Text("Join \(currentUser.name) on a journey of taste")) {
                                Text("Share profile")
                                    .frame(height: 32)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.themeBorder)
                                    .clipShape(.rect(cornerRadius: 5))
                                    .foregroundStyle(Color.primary)
                            }
                        } else {
                            Button {} label: {
                                Text("Share profile")
                                    .frame(height: 32)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.themeBorder)
                                    .clipShape(.rect(cornerRadius: 5))
                                    .foregroundStyle(Color.primary)
                            }
                        }
                        
                        NavigationLink(value: AppRoute.settings) {
                            Image(systemName: "gear")
                                .font(.system(size: 18))
                                .frame(width: 32, height: 32)
                                .background(Color.themeBorder)
                                .clipShape(.rect(cornerRadius: 5))
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .font(.custom(style: .footnote))
                    
                    if let bio = auth.currentUser?.bio {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .footnote))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    HStack {
                        Divider()
                            .opacity(0)
                        
                        Button {
                            appData.myProfileActiveTab = .stats
                        } label: {
                            Text(MyProfileActiveTab.stats.rawValue)
                                .padding(.vertical)
                                .padding(.leading)
                        }
                        .foregroundStyle(
                            appData.myProfileActiveTab == MyProfileActiveTab.stats ? Color.accentColor : Color.secondary
                        )
                        
                        Spacer()
                        Divider()
                            .frame(maxHeight: 20)
                        
                        Button {
                            appData.myProfileActiveTab = .achievements
                        } label: {
                            Text(MyProfileActiveTab.achievements.rawValue)
                                .padding()
                        }
                        .foregroundStyle(
                            appData.myProfileActiveTab == MyProfileActiveTab.achievements ? Color.accentColor : Color.secondary
                        )
                        
                        Divider()
                            .frame(maxHeight: 20)
                        Spacer()
                        
                        Button {
                            appData.myProfileActiveTab = .lists
                        } label: {
                            Text(MyProfileActiveTab.lists.rawValue)
                                .padding(.vertical)
                                .padding(.trailing)
                        }
                        .foregroundStyle(
                            appData.myProfileActiveTab == MyProfileActiveTab.lists ? Color.accentColor : Color.secondary
                        )
                        
                        Divider()
                            .opacity(0)
                    }
                    .font(.custom(style: .footnote))
                    .bold()
                    .textCase(.uppercase)
                    .padding(.horizontal)
                }
                .padding(.top, 8)
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
                    switch appData.myProfileActiveTab {
                    case .stats:
                        ProfileStats()
                    case .achievements:
                        ProfileAchievements()
                    case .lists:
                        MyProfileListsView()
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
            .refreshable {
                await auth.updateUserInfo()
            }
            .frame(maxHeight: .infinity)
            .onChange(of: appData.tappedTwice) { tapped in
                if tapped == .myProfile {
                    withAnimation {
                        proxy.scrollTo(1)
                    }
                    appData.tappedTwice = nil
                }
            }
        }
        .fullScreenCover(isPresented: $appData.showEditProfile) {
            EditProfileView()
        }
        .background {
            VStack(spacing: 0) {
                Color.themePrimary.ignoresSafeArea()
                Color.themeBG.ignoresSafeArea()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    MyProfileView()
}
