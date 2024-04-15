//
//  MainTabBarView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/4/24.
//

import SwiftUI

struct MainTabBarView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var pcVM = PhantomCoinsVM.shared
    @Binding var selection: Tab
    @Binding var showActions: Bool
    
    var body: some View {
        HStack {
            tabView(tab: .home)
            
            tabView(tab: .explore)
            
            Button {
                showActions.toggle()
            } label: {
                Circle()
                    .foregroundStyle(Color.clear)
                    .frame(width: 48, height: 48)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(showActions ? Color.gray : Color.accentColor)
                                .rotationEffect(.degrees(45))
                            
                            Image(systemName: "plus")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .rotationEffect(showActions ? .degrees(135) : .zero)
            .offset(y: -25)
            .animation(.bouncy, value: showActions)
            
            rewardsHubView()
            
            myProfileView()
        }
        .padding(.top, 8)
        .background(.ultraThinMaterial)
    }
}

extension MainTabBarView {
    private func tabView(tab: Tab) -> some View {
        VStack(spacing: 3) {
            Image(tab.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Text(tab.title)
                .font(.custom(style: .caption2))
                .fontWeight(.medium)
        }
        .foregroundStyle(self.selection == tab ? Color.accentColor : Color.secondary)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selection = tab
        }
    }
    
    private func rewardsHubView() -> some View {
        VStack(spacing: 3) {
            Image(Tab.rewardsHub.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .rotation3DEffect(
                    .degrees(self.selection == Tab.rewardsHub ? 180 : 0),
                    axis: (x: 0, y: 1.0, z: 0.0)
                )
                .animation(.bouncy(duration: 0.5), value: self.selection)
                .grayscale(self.selection == Tab.rewardsHub ? 0 : 1)
            
            Text("\((pcVM.balance ?? 0).formattedWithSuffix()) Coins")
                .lineLimit(1)
                .font(.custom(style: .caption2))
                .fontWeight(.medium)
                .redacted(reason: pcVM.balance == nil ? .placeholder : [])
        }
        .foregroundStyle(self.selection == Tab.rewardsHub ? Color.gold : Color.secondary)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selection = Tab.rewardsHub
        }
    }
    
    private func myProfileView() -> some View {
        VStack(spacing: 3) {
            if let currentUser = auth.currentUser {
                ProfileImage(currentUser.profileImage, size: 30, cornerRadius: 15)
            } else {
                Image(Tab.myProfile.imageName)
                    .font(.system(size: 22))
                    .frame(width: 30, height: 30)
            }
            Text(Tab.myProfile.title)
                .font(.custom(style: .caption2))
                .fontWeight(.medium)
        }
        .foregroundStyle(self.selection == Tab.myProfile ? Color.accentColor : Color.secondary)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selection = Tab.myProfile
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        MainTabBarView(selection: .constant(.home), showActions: .constant(false))
    }
}
