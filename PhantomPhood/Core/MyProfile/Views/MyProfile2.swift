//
//  MyProfile.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct MyProfile: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var auth: Authentication
    
    var body: some View {
        NavigationStack(path: $appData.myProfileNavStack) {
            ScrollView {
                VStack {
                    HStack {
                        if let profileImage = auth.user?.profileImage {
                            AsyncImage(url: URL(string: profileImage)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 82, height: 82)
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 15,
                                                bottomLeadingRadius: 15,
                                                bottomTrailingRadius: 15,
                                                topTrailingRadius: 15
                                            )
                                        )
                                } else if phase.error != nil {
                                    VStack(spacing: 0) {
                                        Image(systemName: "exclamationmark.icloud")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.red)
                                            .frame(width: 50, height: 50)
                                        Text("Error")
                                            .font(.caption)
                                    }
                                    .frame(width: 82, height: 82)
                                    .background(Color.themeBG)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 15,
                                            bottomLeadingRadius: 15,
                                            bottomTrailingRadius: 15,
                                            topTrailingRadius: 15
                                        )
                                    )
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 82, height: 82)
                                        .foregroundStyle(.tertiary)
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                            }
                        } else {
                            // No Image
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundStyle(Color.secondary)
                                .frame(width: 50, height: 50)
                                .frame(width: 82, height: 82)
                                .background(Color.themeBG)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 15,
                                        bottomLeadingRadius: 15,
                                        bottomTrailingRadius: 15,
                                        topTrailingRadius: 15
                                    )
                                )
                        }
                        
                        VStack {
                            Text(auth.user?.name ?? "Test User")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("@\(auth.user?.username ?? "testUsername")")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                
                            } label: {
                                Text("Edit Profile")
                                    .frame(maxWidth: .infinity)
                                    
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .controlSize(.small)
                            
                        }.frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    if let bio = auth.user?.bio {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .padding()
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
                    }.padding(.bottom)
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
                    Spacer(minLength: 20)
                    
                    Group {
                        switch appData.myProfileActiveTab {
                        case .stats:
                            VStack(spacing: 50) {
                                
                                VStack {
                                    Text("Social")
                                        .font(.headline)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        DataCard(
                                            icon: "person.2",
                                            iconColor: LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom),
                                            iconBackground: LinearGradient(colors: [Color.blue, Color.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            title: "Followers",
                                            value: "25"
//                                            value: auth.user?.followersCount ? String(auth.user.followersCount) : nil
                                        )
                                        
                                        Spacer()
                                        
                                        DataCard(
                                            icon: "person.3",
                                            iconColor: LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom),
                                            iconBackground: LinearGradient(colors: [Color.blue, Color.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            title: "Followings",
                                            value: "15"
//                                            value: auth.user?.followingCount ? String(auth.user.followingCount) : nil
                                        )
                                    }
                                    
                                }
                                
                                Spacer()

                                
                            }
                            .frame(maxWidth: .infinity, minHeight: 800)
                            .padding()
                            
                                
                        case .achievements:
                            VStack(spacing: 100) {
                                 
                                ForEach(0..<20, id: \.self) { item in
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(height: 50)
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                        case .activity:
                            VStack(spacing: 80) {
                                 
                                ForEach(0..<20, id: \.self) { item in
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(height: 50)
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                }
                .padding(.top)
                .background(Color.themeBG)
                .offset(y: -20)
                .zIndex(-1)
            }
            .refreshable {
                // Refresh
                print("Hey")
            }
            .background(Color.themePrimary)
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

struct MyProfile_Previews: PreviewProvider {
    static var previews: some View {
        MyProfile()
            .environmentObject(AppData())
            .environmentObject(Authentication())
    }
}
