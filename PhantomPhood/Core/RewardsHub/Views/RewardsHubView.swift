//
//  RewardsHubView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/18/24.
//

import SwiftUI

struct RewardsHubView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var pcVM = PhantomCoinsVM.shared
    
    @StateObject private var vm = RewardsHubVM()
    
    @State var isEmojiAnimating: Bool = true
    
    var body: some View {
        NavigationStack(path: $appData.rewardsHubNavStack) {
            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Rewards Hub")
                            .fontWeight(.semibold)
                            .font(.custom(style: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        NavigationLink(value: AppRoute.leaderboard) {
                            VStack(spacing: 0) {
                                Image(.leaderboard)
                                    .foregroundStyle(Color.accentColor)
                                Text("#\(auth.currentUser?.rank ?? 1)")
                                    .font(.custom(style: .caption))
                                    .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                            }
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                    
                    HStack {
                        Image(.phantomCoin)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .shadow(color: Color.coin.opacity(0.3), radius: 10)
                        
                        Text((pcVM.balance ?? 0).formatted())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.coin)
                            .shadow(color: Color.coin.opacity(0.3), radius: 10)
                            .redacted(reason: pcVM.balance == nil ? .placeholder : [])
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Divider()
                
                ScrollView {
                    VStack {
                        HStack(spacing: 3) {
                            Text("Referral Rewards")
                                .padding(.trailing, 5)
                            
                            HStack(spacing: 3) {
                                Image(.phantomCoin)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("250/invite")
                            }
                            
                            Spacer()
                            
                            Text("12")
                            Image(systemName: "person.2.fill")
                        }
                        .font(.custom(style: .headline))
                        
                        Text("Invite your friends to the app and get rewarded as soon as they get into the app")
                            .font(.custom(style: .body))
                            .padding(.top, 2)
                            .padding(.bottom, 8)
                        
                        Button {
                            // TODO: generate invite link
                        } label: {
                            Label {
                                Text("Invite Friend")
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .font(.custom(style: .headline))
                            .frame(maxWidth: .infinity)
                        }
                        .tint(Color.gold)
                        .foregroundStyle(Color.black.opacity(0.9))
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .foregroundStyle(Color.black.opacity(0.9))
                    .padding()
                    .background(Color.accentColor)
                    
                    Section {
                        VStack {
                            HStack {
                                if let dailyRewards = pcVM.dailyRewards, let streaks = pcVM.streaks {
                                    ForEach(dailyRewards.indices, id: \.self) { index in
                                        VStack {
                                            Group {
                                                if streaks == 0 && pcVM.hasClaimedToday {
                                                    Circle()
                                                        .frame(width: 28, height: 28)
                                                        .foregroundStyle(Color.coin)
                                                        .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                        .overlay {
                                                            Image(systemName: "checkmark")
                                                                .foregroundStyle(Color.black)
                                                        }
                                                    
                                                    Text(dailyRewards[index].description)
                                                        .foregroundStyle(Color.secondary)
                                                        .font(.custom(style: .caption))
                                                } else if streaks == index {
                                                    if pcVM.hasClaimedToday {
                                                        Image(.phantomCoin)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .grayscale(1)
                                                            .frame(width: 28, height: 28)
                                                            .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                        
                                                        Text(dailyRewards[index].description)
                                                            .foregroundStyle(Color.secondary)
                                                            .font(.custom(style: .caption))
                                                    } else {
                                                        Image(.phantomCoin)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 28, height: 28)
                                                            .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                            .scaleEffect(1.4)
                                                        
                                                        Text(dailyRewards[index].description)
                                                            .foregroundStyle(Color.primary)
                                                            .font(.custom(style: .caption))
                                                            .fontWeight(.bold)
                                                    }
                                                } else if streaks > index {
                                                    Circle()
                                                        .frame(width: 28, height: 28)
                                                        .foregroundStyle(Color.coin)
                                                        .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                        .overlay {
                                                            Image(systemName: "checkmark")
                                                                .foregroundStyle(Color.black)
                                                        }
                                                    
                                                    Text(dailyRewards[index].description)
                                                        .foregroundStyle(Color.secondary)
                                                        .font(.custom(style: .caption))
                                                } else {
                                                    Image(.phantomCoin)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .grayscale(1)
                                                        .frame(width: 28, height: 28)
                                                        .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                    
                                                    Text(dailyRewards[index].description)
                                                        .foregroundStyle(Color.secondary)
                                                        .font(.custom(style: .caption))
                                                }
                                            }
                                            .animation(.easeIn(duration: 0.5), value: streaks)
                                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .background(alignment: .top) {
                                if let streaks = pcVM.streaks {
                                    ProgressView(value: streaks == 0 && pcVM.hasClaimedToday ? 1 : Double(streaks) / 6)
                                        .padding(.top, 13)
                                        .padding(.horizontal)
                                        .foregroundStyle(Color.coin)
                                        .tint(Color.coin)
                                        .animation(.easeIn(duration: 0.5), value: streaks)
                                }
                            }
                            
                            Button {
                                Task {
                                    await vm.claimDailyReward()
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    if vm.loadingSections.contains(.dailyReward) {
                                        ProgressView()
                                            .controlSize(.regular)
                                    }
                                    
                                    if pcVM.hasClaimedToday, let nextClaimDate = pcVM.nextClaimDate {
                                        TimelineView(.animation(minimumInterval: 1, paused: false)) { _ in
                                            if let remaining = nextClaimDate.remainingTime() {
                                                VStack(spacing: 2) {
                                                    if let streaks = pcVM.streaks {
                                                        if streaks == 0 {
                                                            Text("Refreshes in ")
                                                            Text(remaining)
                                                                .monospaced()
                                                        } else {
                                                            Text(remaining)
                                                                .monospaced()
                                                            Text(" Until next reward")
                                                        }
                                                    } else {
                                                        Text(remaining)
                                                            .monospaced()
                                                        Text(" Until next reward")
                                                    }
                                                }
                                                .foregroundStyle(Color.secondary)
                                                .font(.custom(style: .caption))
                                                .onDisappear {
                                                    Task {
                                                        await pcVM.refresh()
                                                    }
                                                }
                                            } else {
                                                Text("Claim".uppercased())
                                            }
                                        }
                                    } else {
                                        Text("Claim".uppercased())
                                    }
                                }
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.loadingSections.contains(.dailyReward) || pcVM.hasClaimedToday)
                            .animation(.easeInOut, value: vm.loadingSections.contains(.dailyReward) || pcVM.hasClaimedToday)
                        }
                    } header: {
                        Text("Daily Check-in Rewards")
                            .font(.custom(style: .headline))
                            .foregroundStyle(Color.primary.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }
                    .padding(.horizontal)
                    
                    Section {
                        VStack(spacing: 15) {
                            if let missions = vm.missions {
                                if missions.isEmpty {
                                    Text("No missions available")
                                        .font(.custom(style: .headline))
                                        .foregroundStyle(Color.secondary)
                                        .padding(.top)
                                } else {
                                    ForEach(missions) { item in
                                        MissionItem(vm: vm, mission: item, isAnimating: $isEmojiAnimating)
                                    }
                                }
                            } else if vm.loadingSections.contains(.missions) {
                                ForEach(0..<2, id: \.self) { _ in
                                    self.missionPlaceholder
                                }
                            }
                        }
                        .onAppear {
                            Task {
                                await vm.getMissions()
                            }
                        }
                    } header: {
                        HStack {
                            Text("Weekly Missions")
                                .font(.custom(style: .headline))
                                .foregroundStyle(Color.primary.opacity(0.7))
                            
                            Spacer()
                            
                            if vm.loadingSections.contains(.missions) {
                                ProgressView()
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    
                    Section {
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.themeBorder.opacity(0.8))
                                            .frame(width: 135, height: 180)
                                        
                                        Image("AppleGiftcard")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 135, height: 180)
                                    }
                                    .clipShape(.rect(cornerRadius: 10))
                                    
                                    Text("Apple Gift Card")
                                        .font(.custom(style: .headline))
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack(spacing: 5) {
                                        Text("Soon")
                                            .font(.custom(style: .headline))
                                            .foregroundStyle(Color.secondary)
                                        Image(.phantomCoin)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .frame(width: 135)
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.never)
                        .padding(.bottom, 40)
                    } header: {
                        Text("Redeem")
                            .font(.custom(style: .headline))
                            .foregroundStyle(Color.primary.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.horizontal)
                    }
                }
                .refreshable {
                    await pcVM.refresh()
                    await vm.getMissions()
                }
                .font(.custom(style: .body))
                .scrollIndicators(.never)
            }
            .background {
                Rectangle()
                    .fill(.themeBG.gradient)
                    .ignoresSafeArea()
            }
            .onAppear {
                isEmojiAnimating = true
                Task {
                    await pcVM.refresh()
                }
            }
            .onDisappear {
                isEmojiAnimating = false
            }
            .handleNavigationDestination()
        }
    }
    
    var missionPlaceholder: some View {
        HStack {
            Circle()
                .foregroundStyle(Color.themeBorder)
                .frame(width: 46, height: 46)
            
            VStack {
                Text("Title")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.primary)
                Text("Subtitle placeholder")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.secondary)
                    .font(.custom(style: .subheadline))
            }
            .fontWeight(.medium)
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 5) {
                    Spacer()
                    
                    Text("50")
                        .font(.custom(style: .headline))
                        .foregroundStyle(Color.primary)
                    Image(.phantomCoin)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
                VStack(spacing: 0) {
                    Text("0/16")
                        .font(.custom(style: .caption))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle())
                }
                
            }
            .frame(maxWidth: 110)
        }
        .padding(.all, 8)
        .background(Color.themePrimary)
        .clipShape(.rect(cornerRadius: 10))
        .redacted(reason: .placeholder)
    }
}

fileprivate struct MissionItem: View {
    @ObservedObject var vm: RewardsHubVM
    let mission: Mission
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.themeBorder)
                        .frame(width: 46, height: 46)
                        .overlay {
                            Emoji(symbol: mission.icon, isAnimating: $isAnimating, size: 28)
                        }
                        .shadow(color: Color.themeBG.opacity(0.2), radius: 3)
                    
                    Spacer()
                        .frame(width: 1)
                        .frame(minHeight: 0)
                        .background(Color.themeBorder)
                        .shadow(color: Color.themeBG.opacity(0.2), radius: 2)
                }
                .padding(.all, 8)
                
                VStack {
                    HStack {
                        VStack {
                            Text(mission.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.primary)
                            if let subtitle = mission.subtitle {
                                Text(subtitle)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color.secondary)
                                    .font(.custom(style: .subheadline))
                            }
                            
                            Spacer()
                                .frame(minHeight: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(.medium)
                        .padding(.top, 8)
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            if mission.isClaimed {
                                Text("CLAIMED")
                                    .font(.custom(style: .headline))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.all, 8)
                                    .background(Color.themeBorder)
                                    .clipShape(.rect(topLeadingRadius: 2, bottomLeadingRadius: 8, bottomTrailingRadius: 2, topTrailingRadius: 8))
                                    .shadow(color: Color.black.opacity(0.3), radius: 0, x: -1, y: 1)
                            } else {
                                if mission.progress.completed >= mission.progress.total {
                                    Button {
                                        Task {
                                            await vm.claimMissions(id: mission.id)
                                        }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text("CLAIM \(mission.rewardAmount)")
                                                .font(.custom(style: .headline))
                                                .foregroundStyle(Color.white.opacity(0.9))
                                                .fontWidth(.compressed)
                                            Image(.phantomCoin)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                        }
                                        .padding(.all, 8)
                                        .background(Color.accentColor)
                                        .clipShape(.rect(topLeadingRadius: 2, bottomLeadingRadius: 8, bottomTrailingRadius: 2, topTrailingRadius: 8))
                                        .shadow(color: Color.black.opacity(0.3), radius: 0, x: -2, y: 2)
                                        .offset(x: 3, y: -3)
                                    }
                                    .disabled(vm.loadingSections.contains(.missions) || vm.loadingSections.contains(.mission(mission.id)))
                                    .animation(.easeInOut, value: mission.isClaimed)
                                } else {
                                    HStack(spacing: 5) {
                                        Text(mission.rewardAmount.description)
                                            .font(.custom(style: .headline))
                                            .foregroundStyle(Color.primary)
                                        Image(.phantomCoin)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(.all, 8)
                                    .background(Color.themeBorder)
                                    .clipShape(.rect(topLeadingRadius: 2, bottomLeadingRadius: 8, bottomTrailingRadius: 2, topTrailingRadius: 8))
                                    .shadow(color: Color.black.opacity(0.3), radius: 0, x: -2, y: 2)
                                    .offset(x: 3, y: -3)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(mission.progress.completed.description)/\(mission.progress.total.description)")
                                .font(.custom(style: .caption))
                                .foregroundStyle(Color.secondary)
                                .padding(.trailing, 8)
                        }
                    }
                    
                    ProgressView(value: min(Double(mission.progress.completed) / Double(mission.progress.total == 0 ? 1 : mission.progress.total), 1))
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.bottom, 8)
                        .padding(.trailing, 8)
                }
            }
            .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.themePrimary))
            
            if let date = DateFormatter.stringToDate(dateString: mission.expiresAt){
                TimelineView(.animation(minimumInterval: 1, paused: false)) { _ in
                    if let remaining = date.remainingTime() {
                        Text(remaining + " remaining")
                            .foregroundStyle(.tertiary)
                            .monospaced()
                            .font(.custom(style: .caption2))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RewardsHubView()
}
