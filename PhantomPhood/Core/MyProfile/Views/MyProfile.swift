//
//  MyProfile.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI
import Kingfisher

struct MyProfile: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var auth: Authentication
    
    var body: some View {
        NavigationStack(path: $appData.myProfileNavStack) {
            ScrollView {
                VStack {
                    HStack(spacing: 12) {
                        if let user = auth.currentUser, !user.profileImage.isEmpty, let imageURL = URL(string: user.profileImage) {
                            KFImage.url(imageURL)
                                .placeholder { progress in
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.tertiary)
                                        .overlay {
                                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                .progressViewStyle(LinearProgressViewStyle())
                                        }
                                }
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .fade(duration: 0.5)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 82, height: 82)
                                .contentShape(Rectangle())
                                .clipShape(.rect(cornerRadius: 15))
                        } else {
                            // No Image
                            if auth.currentUser == nil {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 82, height: 82)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 82, height: 82)
                                    .background(Color.themeBG)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            
                        }
                        
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
                        .frame(maxWidth: .infinity)
                    }
                    .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                    .padding(.horizontal)
                    .padding(.bottom)

                    if let bio = auth.currentUser?.bio, bio.count > 0 {
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
                
                
                VStack {
                    Group {
                        switch appData.myProfileActiveTab {
                        case .stats:
                            ProfileStats()
                        case .achievements:
                            VStack {
                                Text("No Achievements yet")
                                    .font(.custom(style: .headline))
                            }
                            .frame(maxWidth: .infinity)
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
        }
    }
}

#Preview {
    MyProfile()
        .environmentObject(AppData())
        .environmentObject(Authentication())
}
