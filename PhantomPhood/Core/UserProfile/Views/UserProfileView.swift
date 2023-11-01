//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI
import Kingfisher

enum UserProfileTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case activity = "Activity"
    case checkins = "Checkins"
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
                    if let user = vm.user, !user.profileImage.isEmpty, let imageURL = URL(string: user.profileImage) {
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
                        .font(.custom(style: .footnote))
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
                        
                        ForEach(UserProfileTab.allCases.indices, id: \.self) { i in
                            Button {
                                withAnimation {
                                    activeTab = UserProfileTab.allCases[i]
                                }
                            } label: {
                                Text(UserProfileTab.allCases[i].rawValue)
                                    .font(.custom(style: .footnote))
                                    .bold()
                                    .textCase(.uppercase)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .foregroundStyle(
                                activeTab == UserProfileTab.allCases[i] ? Color.accentColor : Color.secondary
                            )
                            .padding(i == 0 ? .trailing : i == UserProfileTab.allCases.count - 1 ? .leading : .horizontal)
                            
                            if i != UserProfileTab.allCases.count - 1 {
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
//                HStack {
//                    ForEach(UserProfileTab.allCases.indices, id: \.self) { i in
//                        Button {
//                            withAnimation {
//                                activeTab = UserProfileTab.allCases[i]
//                            }
//                        } label: {
//                            Text(UserProfileTab.allCases[i].rawValue)
//                                .foregroundStyle(
//                                    activeTab == UserProfileTab.allCases[i] ? Color.accentColor : Color.secondary
//                                )
//                                .font(.custom(style: .footnote))
//                                .bold()
//                                .textCase(.uppercase)
//                                .frame(maxWidth: .infinity, alignment: .center)
//                        }
//                        
//                        if i != UserProfileTab.allCases.count - 1 {
//                            Divider()
//                        }
//                    }
//                }.padding(.bottom)
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
                        }
                        .frame(maxWidth: .infinity)
                    case .activity:
                        VStack {
                            Text("No Activity yet")
                                .font(.custom(style: .headline))
                        }
                        .frame(maxWidth: .infinity)
                    case .checkins:
                        VStack {
                            Text("No Checkins yet")
                                .font(.custom(style: .headline))
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
