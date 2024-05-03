//
//  RewardsHubView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/18/24.
//

import SwiftUI

struct RewardsHubView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var pcVM = PhantomCoinsVM.shared
    
    @EnvironmentObject private var inviteFriendsVM: InviteFriendsVM
    
    @StateObject private var vm = RewardsHubVM()
    
    @State var isEmojiAnimating: Bool = true
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                
                Divider()
                
                ScrollView {
                    ReferralSection()
                    
                    dailycheckinsSection
                    
                    missionsSection
                    
                    prizesSection
                        .padding(.bottom, 30)
                }
                .refreshable {
                    Task {
                        await pcVM.refresh()
                    }
                    Task {
                        await vm.getMissions()
                    }
                    Task {
                        await vm.getPrizes()
                    }
                    
                    inviteFriendsVM.addRemoveInviteLinks(inviteFriendsVM.inviteLinks)
                }
                .font(.custom(style: .body))
                .scrollIndicators(.never)
            }
            
            if let selectedPrize = vm.selectedPrize {
                ZStack {
                    Color.black.opacity(0.85)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                vm.selectedPrize = nil
                            }
                        }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.themePrimary)
                            .frame(maxWidth: .infinity, maxHeight: 196)
                            .matchedGeometryEffect(id: "\(selectedPrize.id)-bg", in: namespace)
                        
                        HStack(alignment: .top) {
                            ImageLoader(selectedPrize.thumbnail, contentMode: .fill) { progress in
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(maxWidth: 150)
                                    .overlay {
                                        ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .padding(.horizontal)
                                    }
                            }
                            .matchedGeometryEffect(id: "\(selectedPrize.id)-img", in: namespace)
                            .frame(width: 135, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack {
                                Text(selectedPrize.title)
                                    .font(.custom(style: .body))
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Our support team will contact you shortly to arrange delivery.")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                                
                                Text("Tap 'Redeem' to claim your prize!")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let balance = pcVM.balance {
                                    Button {
                                        Task {
                                            await vm.redeemPrize(id: selectedPrize.id)
                                        }
                                    } label: {
                                        ZStack {
                                            VStack(spacing: 0) {
                                                Text(balance >= selectedPrize.amount ? "Redeem".uppercased() : "Not Enough Coin".uppercased())
                                                    .font(.custom(style: .subheadline))
                                                    .fontWeight(.semibold)
                                                
                                                HStack(spacing: 3) {
                                                    Image(.Icons.phantomCoin)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 18, height: 18)
                                                        .shadow(color: Color.themeBG.opacity(0.15), radius: 3)
                                                    
                                                    Text(selectedPrize.amount.formattedWithSuffix())
                                                        .font(.custom(style: .subheadline))
                                                        .fontWeight(.semibold)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .opacity(vm.loadingSections.contains(.redeeming) ? 0 : 1)
                                            
                                            if vm.loadingSections.contains(.redeeming) {
                                                ProgressView()
                                            }
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(balance < selectedPrize.amount)
                                }
                            }
                            .frame(height: 180)
                        }
                        .padding(.all, 8)
                    }
                    .padding()
                }
                .zIndex(5)
            }
        }
        .background {
            Rectangle()
                .fill(.themeBG.gradient)
                .ignoresSafeArea()
        }
        .onDisappear {
            isEmojiAnimating = false
        }
        .onAppear {
            isEmojiAnimating = true
            inviteFriendsVM.addRemoveInviteLinks(inviteFriendsVM.inviteLinks)
        }
        .task {
            await pcVM.refresh()
        }
    }
    
    var header: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Rewards Hub")
                    .fontWeight(.semibold)
                    .font(.custom(style: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                NavigationLink(value: AppRoute.leaderboard) {
                    VStack(spacing: 0) {
                        Image(.Icons.leaderboard)
                            .foregroundStyle(Color.accentColor)
                        Text("#\(auth.currentUser?.rank ?? 1)")
                            .font(.custom(style: .caption))
                            .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                    }
                }
                .foregroundStyle(Color.accentColor)
            }
            
            HStack {
                Image(.Icons.phantomCoin)
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
    }
    
    @ViewBuilder
    private func ReferralSection() -> some View {
        VStack {
            HStack(spacing: 3) {
                Text("Referral Rewards")
                    .padding(.trailing, 5)
                
                HStack(spacing: 3) {
                    Image(.Icons.phantomCoin)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text("250/invite")
                }
                
                Spacer()
                
                Text(UserSettings.shared.inviteCredits.description)
                
                Image(systemName: "person.2.fill")
            }
            .padding(.horizontal)
            .font(.custom(style: .headline))
            
            Text("Invite your friends to the app and get rewarded as soon as they get into the app")
                .font(.custom(style: .body))
                .padding(.horizontal)
                .padding(.bottom, 6)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(inviteFriendsVM.referredUsers.count > 3 ? inviteFriendsVM.referredUsers.prefix(3).reversed() : inviteFriendsVM.referredUsers.reversed(), id: \.self) { user in
                        NavigationLink(value: AppRoute.userProfile(userId: user.id ?? "-")) {
                            VStack(spacing: 4) {
                                ProfileImage(URL(string: user.profileImage ?? ""), size: 50, cornerRadius: 25)
                                Text(user.name ?? "-")
                                    .lineLimit(1)
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: 50)
                        }
                    }
                    
                    if !inviteFriendsVM.referredUsers.isEmpty && !inviteFriendsVM.inviteLinks.isEmpty {
                        Divider()
                            .frame(maxHeight: 40)
                    }
                    
                    ForEach(inviteFriendsVM.inviteLinks) { link in
                        if let expiresIn = link.expiresAt.remainingTime(), let url = link.link {
                            ShareLink(item: url) {
                                VStack(spacing: 4) {
                                    ProfileImage(nil, size: 50, cornerRadius: 25)
                                        .overlay {
                                            Circle()
                                                .foregroundStyle(Color.black.opacity(0.6))
                                            
                                            Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.white.opacity(0.7))
                                        }
                                    Text(expiresIn)
                                        .lineLimit(1)
                                        .font(.custom(style: .caption2))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: 50)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.never)
            
            Button {
                inviteFriendsVM.generateInviteLink()
            } label: {
                if UserSettings.shared.inviteCredits > 0 {
                    HStack {
                        if inviteFriendsVM.loadingSections.contains(.inviteLink) {
                            ProgressView()
                                .controlSize(.regular)
                                .tint(Color.black.opacity(0.8))
                                .padding(.trailing, 3)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Invite Friend")
                    }
                    .frame(maxWidth: .infinity)
                    .font(.custom(style: .headline))
                } else {
                    Text("Out of Invites")
                        .font(.custom(style: .subheadline))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .tint(Color.gold.gradient)
            .foregroundStyle(Color.black.opacity(0.9))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(UserSettings.shared.inviteCredits <= 0)
            .padding(.horizontal)
        }
        .foregroundStyle(Color.black.opacity(0.9))
        .padding(.vertical)
        .background(Color.accentColor.gradient)
    }
    
    var dailycheckinsSection: some View {
        Section {
            VStack {
                HStack {
                    if let dailyRewards = pcVM.dailyRewards, let streaks = pcVM.streaks {
                        ForEach(dailyRewards.indices, id: \.self) { index in
                            VStack {
                                Image(.Icons.phantomCoin)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .grayscale(pcVM.hasClaimedToday || index > streaks ? 1 : 0)
                                    .frame(width: 28, height: 28)
                                    .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                    .scaleEffect(streaks == index && !pcVM.hasClaimedToday ? 1.4 : 1)
                                    .animation(.easeOut(duration: 0.5), value: streaks)
                                    .overlay {
                                        if streaks > index || streaks == 0 && pcVM.hasClaimedToday {
                                            Circle()
                                                .frame(width: 28, height: 28)
                                                .foregroundStyle(Color.coin)
                                                .shadow(color: Color.themeBG.opacity(0.3), radius: 3)
                                                .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.1).delay(0.2)))
                                        }
                                    }
                                    .overlay {
                                        if streaks > index || streaks == 0 && pcVM.hasClaimedToday {
                                            Image(systemName: "checkmark")
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color.black.opacity(0.8))
                                                .transition(AnyTransition.scale(scale: 1.5).combined(with: .opacity).animation(.easeOut(duration: 0.25).delay(0.3)))
                                        }
                                    }
                                
                                Text(dailyRewards[index].description)
                                    .foregroundStyle(streaks == index && !pcVM.hasClaimedToday ? Color.primary : Color.secondary)
                                    .font(.custom(style: .caption))
                                    .fontWeight(streaks == index && !pcVM.hasClaimedToday ? .bold : .regular)
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
    }
    
    var missionsSection: some View {
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
                    ForEach(RepeatItem.create(2)) { _ in
                        MissionItem.placeholder
                    }
                }
            }
            .task {
                await vm.getMissions()
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
    }
    
    var prizesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 20) {
                    if let prizes = vm.prizes {
                        if prizes.isEmpty {
                            Text("No prize available")
                                .font(.custom(style: .headline))
                                .foregroundStyle(Color.secondary)
                                .padding(.top)
                        } else {
                            ForEach(prizes) { item in
                                ZStack {
                                    Color.clear
                                        .frame(width: 135)
                                    
                                    if let selectedPrize = vm.selectedPrize, selectedPrize.id == item.id {
                                        EmptyView()
                                    } else {
                                        PrizeItem(vm: vm, data: item, namespace: namespace)
                                    }
                                }
                            }
                        }
                    } else if vm.loadingSections.contains(.prizes) {
                        ForEach(RepeatItem.create(2)) { _ in
                            PrizeItem.placeholder
                        }
                    }
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
}

#Preview {
    RewardsHubView()
}
