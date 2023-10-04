//
//  MyProfile.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI

struct MyProfile: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var auth: Authentication
    
    var body: some View {
        NavigationStack(path: $appData.myProfileNavStack) {
            ScrollView {
                VStack {
                    HStack(spacing: 12) {
                        if let profileImage = auth.user?.profileImage, let imageURL = URL(string: profileImage) {
                            AsyncImageLoader(imageURL) {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .overlay {
                                        ProgressView()
                                    }
                            } errorView: {
                                VStack(spacing: 0) {
                                    Image(systemName: "exclamationmark.icloud")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.red)
                                        .frame(width: 50, height: 50)
                                    Text("Error")
                                        .font(.caption)
                                }
                                .background(Color.themeBG)
                            }
                            .frame(width: 82, height: 82)
                            .clipShape(.rect(cornerRadius: 15))
                        } else {
                            // No Image
                            if auth.user == nil {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 82, height: 82)
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 50, height: 50)
                                    .frame(width: 82, height: 82)
                                    .background(Color.themeBG)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            
                        }
                        
                        VStack {
                            if (auth.user != nil && auth.user!.verified) {
                                HStack {
                                    Text(auth.user?.name ?? "User Name")
                                        .font(.title2)
                                        .bold()
                                    Image(systemName: "checkmark.seal")
                                        .foregroundStyle(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            } else {
                                Text(auth.user?.name ?? "User Name")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Text("@\(auth.user?.username ?? "testUsername")")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                appData.showEditProfile.toggle()
                            } label: {
                                Text("Edit Profile")
                                    .frame(maxWidth: .infinity)
                                    
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .controlSize(.small)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .redacted(reason: auth.user == nil ? .placeholder : [])
                    .padding(.horizontal)
                    .padding(.bottom)

                    if let bio = auth.user?.bio, bio.count > 0 {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    HStack {
                        ForEach(MyProfileActiveTab.allCases.indices, id: \.self) { i in
                            Button {
                                withAnimation {
                                    appData.myProfileActiveTab = MyProfileActiveTab.allCases[i]
                                }
                            } label: {
                                Text(MyProfileActiveTab.allCases[i].rawValue)
                                    .foregroundStyle(
                                        appData.myProfileActiveTab == MyProfileActiveTab.allCases[i] ? Color.accentColor : Color.secondary
                                    )
                                    .font(.footnote)
                                    .bold()
                                    .controlSize(.small)
                                    .textCase(.uppercase)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            if i != MyProfileActiveTab.allCases.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .padding(.bottom)
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
                                Text("Comming Soon")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        case .activity:
                            VStack {
                                Text("No Activity yet")
                                    .font(.custom(style: .headline))
                                Text("Comming Soon")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(minHeight: UIScreen.main.bounds.height / 2)
                .background(
                    Color.themeBG
                        .offset(y: -30)
                )
                .zIndex(-1)
            }
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
                case .place(let id):
                    PlaceView(id: id)
                case .userProfile(let id):
                    UserProfileView(id: id)
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
