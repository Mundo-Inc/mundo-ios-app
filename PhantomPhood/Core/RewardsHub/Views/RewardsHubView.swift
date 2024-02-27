//
//  RewardsHubView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/18/24.
//

import SwiftUI
import Kingfisher

struct RewardsHubView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var pcVM = PhantomCoinsVM.shared
    
    @StateObject private var vm = RewardsHubVM()
    
    @State var isEmojiAnimating: Bool = true
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack(path: $appData.rewardsHubNavStack) {
            ZStack {
                VStack(spacing: 0) {
                    header
                    
                    Divider()
                    
                    ScrollView {
                        ReferralSection()
                        
                        dailycheckinsSection
                        
                        missionsSection
                        
                        prizesSection
                    }
                    .refreshable {
                        await pcVM.refresh()
                        await vm.getMissions()
                        await vm.getPrizes()
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
                                KFImage.url(selectedPrize.thumbnail)
                                    .placeholder {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.themePrimary)
                                            .overlay {
                                                ProgressView()
                                            }
                                    }
                                    .loadDiskFileSynchronously()
                                    .fade(duration: 0.25)
                                    .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 135, height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                    .matchedGeometryEffect(id: "\(selectedPrize.id)-img", in: namespace)
                                
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
                                                        Image(.phantomCoin)
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
    
    var header: some View {
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
    }
    
    @ViewBuilder
    private func ReferralSection() -> some View {
        VStack {
            HStack(alignment: .top, spacing: 3) {
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
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(spacing: 3) {
                        Text(UserSettings.shared.inviteCredits.description)
                        Image(systemName: "person.2.fill")
                    }
                    if UserSettings.shared.inviteCredits != 0 && UserSettings.shared.inviteCredits != UserSettings.maxInviteCredits {
                        TimelineView(.animation(minimumInterval: 1, paused: false)) { _ in
                            Text("+1 in " + (UserSettings.shared.inviteCreditsLastGiven.addingTimeInterval(3600 * 24 * 7).remainingTime() ?? "7 days"))
                                .font(.custom(style: .caption))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .font(.custom(style: .headline))
            
            Text("Invite your friends to the app and get rewarded as soon as they get into the app")
                .font(.custom(style: .body))
                .padding(.top, 2)
                .padding(.bottom, 8)
            
            if let userInviteLinks = vm.userInviteLinks {
                HStack {
                    ForEach(userInviteLinks.count > 5 ? Array(userInviteLinks.prefix(upTo: 5)) : userInviteLinks) { link in
                        Group {
                            if let referredUser = link.referredUser {
                                VStack {
                                    if let invitedUsersList = vm.invitedUsersList, let found = invitedUsersList.first(where: { $0.id == referredUser }) {
                                        ProfileImage(found.profileImage, size: 50, cornerRadius: 25)
                                        Text(found.name)
                                    } else {
                                        ProfileImage("", size: 50, cornerRadius: 25)
                                        Text("Name")
                                            .foregroundStyle(.black.opacity(0.5))
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .onTapGesture {
                                    appData.goTo(AppRoute.userProfile(userId: referredUser))
                                }
                            } else if let expiresIn = link.expiresAt.remainingTime(), let url = link.link {
                                VStack {
                                    ShareLink(item: url) {
                                        ZStack {
                                            ProfileImage("", size: 50, cornerRadius: 25)
                                            
                                            Circle()
                                                .frame(width: 50, height: 50)
                                                .foregroundStyle(Color.black.opacity(0.6))
                                            
                                            Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.white.opacity(0.7))
                                        }
                                    }
                                    
                                    Text(expiresIn)
                                        .foregroundStyle(.black.opacity(0.5))
                                }
                            }
                        }
                        .font(.custom(style: .caption2))
                        .fontWeight(.semibold)
                    }
                }
            }
            
            Button {
                vm.getInviteLink()
            } label: {
                if UserSettings.shared.inviteCredits > 0 {
                    HStack {
                        if vm.loadingSections.contains(.inviteLink) {
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
                    if let userInviteLinks = vm.userInviteLinks, userInviteLinks.filter({ $0.referredUser == nil }).count == UserSettings.maxInviteCredits {
                        Text("Out of Invites")
                            .font(.custom(style: .subheadline))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 0) {
                            Text("Out of Invites")
                                .font(.custom(style: .subheadline))
                                .fontWeight(.semibold)
                            
                            TimelineView(.animation(minimumInterval: 1, paused: false)) { _ in
                                Text(UserSettings.shared.inviteCreditsLastGiven.addingTimeInterval(3600 * 24 * 2).remainingTime() ?? "2 days")
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .tint(Color.gold.gradient)
            .foregroundStyle(Color.black.opacity(0.9))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(UserSettings.shared.inviteCredits <= 0)
        }
        .foregroundStyle(Color.black.opacity(0.9))
        .padding()
        .background(Color.accentColor.gradient)
    }
    
    var dailycheckinsSection: some View {
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
