//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

enum UserProfileTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case activity = "Activity"
}


struct UserProfileView: View {
    let id: String
    
    @StateObject private var vm: UserProfileViewModel
    @State private var activeTab: UserProfileTab = .stats
        
    init(id: String) {
        self.id = id
        self._vm = StateObject(wrappedValue: UserProfileViewModel(id: id))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 12) {
                    if let profileImage = vm.user?.profileImage, let imageURL = URL(string: profileImage) {
                        CacheAsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .overlay {
                                        ProgressView()
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                VStack(spacing: 0) {
                                    Image(systemName: "exclamationmark.icloud")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.red)
                                        .frame(width: 50, height: 50)
                                    Text("Error")
                                        .font(.custom(style: .caption))
                                }
                                .background(Color.themeBG)
                            }
                        }
                        .frame(width: 82, height: 82)
                        .contentShape(Rectangle())
                        .clipShape(.rect(cornerRadius: 15))
                    } else {
                        // No Image
                        if vm.user == nil {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.tertiary)
                                .frame(width: 82, height: 82)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.secondary)
                                .frame(width: 82, height: 82)
                                .background(Color.themeBG)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                    }
                    
                    VStack {
                        if (vm.user != nil && vm.user!.verified) {
                            HStack {
                                Text(vm.user?.name ?? "User Name")
                                    .font(.title2)
                                    .bold()
                                Image(systemName: "checkmark.seal")
                                    .foregroundStyle(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        } else {
                            Text(vm.user?.name ?? "User Name")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text("@\(vm.user?.username ?? "Loading")")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Group {
                            if let isFollowing = vm.isFollowing {
                                if isFollowing {
                                    Button {
                                        Task {
                                            await vm.unfollow()
                                        }
                                    } label: {
                                        Text("Unfollow")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                } else {
                                    Button {
                                        Task {
                                            await vm.follow()
                                        }
                                    } label: {
                                        Text("Follow")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(BorderedProminentButtonStyle())
                                }
                            } else {
                                Button {} label: {
                                    Text("Loading")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }
                        }
                        .controlSize(.small)
                        
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .redacted(reason: vm.user == nil ? .placeholder : [])
                
                if let bio = vm.user?.bio, bio.count > 0 {
                    Text(bio)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                HStack {
                    ForEach(UserProfileTab.allCases.indices, id: \.self) { i in
                        Button {
                            withAnimation {
                                activeTab = UserProfileTab.allCases[i]
                            }
                        } label: {
                            Text(UserProfileTab.allCases[i].rawValue)
                                .foregroundStyle(
                                    activeTab == UserProfileTab.allCases[i] ? Color.accentColor : Color.secondary
                                )
                                .font(.footnote)
                                .bold()
                                .controlSize(.small)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        if i != UserProfileTab.allCases.count - 1 {
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
                Group {
                    switch activeTab {
                    case .stats:
                        UserProfileStats(user: vm.user)
                        
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
        .refreshable {
            await vm.fetchUser()
        }
        .frame(maxHeight: .infinity)
        .background(
            VStack {
                Color.themePrimary.ignoresSafeArea()
                Color.themeBG.ignoresSafeArea()
            }
                .frame(maxHeight: .infinity)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UserProfileView(id: "645c8b222134643c020860a5")
}
