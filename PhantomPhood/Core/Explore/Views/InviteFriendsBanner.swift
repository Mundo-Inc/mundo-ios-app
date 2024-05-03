//
//  InviteFriendsBanner.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/19/24.
//

import SwiftUI

struct InviteFriendsBanner: View {
    static let maxReferredUsersDisplayCount: Int = 2
    
    @EnvironmentObject private var vm: InviteFriendsVM
    
    @State private var show: Bool = false
    
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Invite More Friends!")
                        .font(.custom(style: .title2))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundStyle(.themePrimary)
                            .frame(width: 20, height: 20)
                            .background(Color.primary, in: RoundedRectangle(cornerRadius: 5))
                    }
                }
                
                Text("Invite more friends to see their activity on the map")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 80)
                
                HStack(spacing: 8) {
                    ForEach(vm.referredUsers.count > Self.maxReferredUsersDisplayCount ? vm.referredUsers.prefix(Self.maxReferredUsersDisplayCount).reversed() : vm.referredUsers.reversed(), id: \.self) { user in
                        NavigationLink(value: AppRoute.userProfile(userId: user.id ?? "-")) {
                            VStack(spacing: 4) {
                                ProfileImage(URL(string: user.profileImage ?? ""), size: 42, cornerRadius: 21)
                                Text(user.name ?? "-")
                                    .lineLimit(1)
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: 42)
                        }
                    }
                    
                    Button {
                        vm.generateInviteLink()
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .frame(width: 42, height: 42)
                                .foregroundStyle(.tertiary)
                                .shadow(radius: 5)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .semibold))
                                }
                            
                            Text("Add")
                                .lineLimit(1)
                                .font(.custom(style: .caption2))
                        }
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.primary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .padding(.all, 8)
            
            Image(.sparkles)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(show ? -20 : 0))
                .offset(x: -20, y: -20)
                .scaleEffect(show ? 1 : 0, anchor: .topLeading)
                .animation(.bouncy.delay(0.1), value: show)
            
            Image(.sparkles)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(show ? -20 : 0))
                .offset(x: -108, y: -79)
                .scaleEffect(show ? 1 : 0, anchor: .topLeading)
                .animation(.bouncy.delay(0.2), value: show)
            
            Image(.laughing)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(show ? -15 : 0))
                .offset(x: -67, y: -82)
                .scaleEffect(show ? 1 : 0, anchor: .topLeading)
                .animation(.bouncy.delay(0.05), value: show)
            
            Image(.heartEyes)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(show ? 8 : 0))
                .offset(x: -5, y: -55)
                .scaleEffect(show ? 1 : 0, anchor: .topLeading)
                .animation(.bouncy, value: show)
            
            Image(.cool)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 85, height: 85)
                .rotationEffect(.degrees(show ? -15 : 0))
                .offset(x: -50, y: -5)
                .scaleEffect(show ? 1 : 0, anchor: .topLeading)
                .animation(.bouncy, value: show)
        }
        .onAppear {
            show = true
        }
        .onDisappear {
            show = false
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        InviteFriendsBanner {
            
        }
    }
}
