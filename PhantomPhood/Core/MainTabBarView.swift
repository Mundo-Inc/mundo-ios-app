//
//  MainTabBarView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/4/24.
//

import SwiftUI

struct MainTabBarView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var earningsVM = EarningsVM.shared
    @Binding private var selection: Tab
    
    init(selection: Binding<Tab>) {
        self._selection = selection
    }
    
    var body: some View {
        HStack {
            tabView(tab: .home)
            
            tabView(tab: .explore)
            
            Button {
                SheetsManager.shared.presenting = .placeSelector(onSelect: { mapItem in
                    if let name = mapItem.name {
                        AppData.shared.goTo(.checkIn(.mapPlace(.init(coordinate: mapItem.placemark.coordinate, title: name))))
                    }
                })
            } label: {
                Circle()
                    .foregroundStyle(Color.clear)
                    .frame(width: 48, height: 48)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color.accentColor)
                                .rotationEffect(.degrees(45))
                            
                            Image(systemName: "plus")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .offset(y: -25)
            
            rewardsHubView
            
            myProfileView
        }
        .padding(.top, 6)
        .background(.ultraThinMaterial)
    }
}

extension MainTabBarView {
    private func tabView(tab: Tab) -> some View {
        VStack(spacing: 3) {
            tab.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text(tab.title)
                .cfont(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(self.selection == tab ? Color.accentColor : Color.secondary)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selection = tab
        }
    }
    
    private var rewardsHubView: some View {
        VStack(spacing: 3) {
            Tab.rewardsHub.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .rotation3DEffect(
                    .degrees(self.selection == Tab.rewardsHub ? 180 : 0),
                    axis: (x: 0, y: 1.0, z: 0.0)
                )
                .animation(.bouncy(duration: 0.5), value: self.selection)
                .grayscale(self.selection == Tab.rewardsHub ? 0 : 1)
            
            Group {
                if let text = earningsVM.data?.balance.asCurrency() {
                    Text(text)
                        .lineLimit(1)
                } else {
                    Text("$0000")
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                }
            }
            .cfont(.caption2)
            .fontWeight(.medium)
            
        }
        .foregroundStyle(self.selection == Tab.rewardsHub ? Color.gold : Color.secondary)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selection = Tab.rewardsHub
        }
    }
    
    private var myProfileView: some View {
        VStack(spacing: 3) {
            if let currentUser = auth.currentUser {
                ProfileImage(currentUser.profileImage, size: 30, cornerRadius: 15)
            } else {
                Tab.myProfile.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            Text(Tab.myProfile.title)
                .cfont(.caption2)
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
        
        MainTabBarView(selection: .constant(.home))
    }
}
