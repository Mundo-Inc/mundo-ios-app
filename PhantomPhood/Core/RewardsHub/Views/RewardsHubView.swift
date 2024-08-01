//
//  RewardsHubView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/18/24.
//

import SwiftUI

struct RewardsHubView: View {
    private let cardsCornerRadious: CGFloat = 12
    
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var earningsVM = EarningsVM.shared
    
    @StateObject private var vm = RewardsHubVM()
    
    var body: some View {
        ScrollView {
            VStack {
                StreakCard()
                
                CashCard()
                
                HStack {
                    PublicPostsCard()
                    
                    UniqueReactionsCard()
                }
                
                LeaderboardCard()
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .refreshable {
            Task {
                await vm.getStats()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Rectangle().foregroundStyle(Color.themeBG.gradient).ignoresSafeArea())
        .fullScreenCover(isPresented: $vm.showingHowItWorks) {
            if #available(iOS 16.4, *) {
                HowItWorksLayer()
                    .presentationBackground(.ultraThinMaterial)
            } else {
                HowItWorksLayer()
            }
        }
        .task {
            await vm.getStats()
        }
    }
    
    @ViewBuilder
    private func HowItWorksLayer() -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("How It Works")
                        .cfont(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            vm.showingHowItWorks = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                Text("Earn by adding check-ins and including images or videos in your posts.")
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Each post containing media")
                    
                    Spacer()
                    
                    Text("$0.2")
                        .cfont(.title3)
                        .foregroundStyle(Color.accentColor)
                }
                
                HStack {
                    Text("Each 10 unique reactions\n(from different users)")
                    
                    Spacer()
                    
                    Text("$0.05")
                        .cfont(.title3)
                        .foregroundStyle(Color.accentColor)
                }

                Text("You can cash out your earnings once you reach a minimum of **$25**.")
            }
            .padding(.all, 20)
            .background(Color.themePrimary, in: .rect(cornerRadius: 25))
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func StreakCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text("Daily Streak")
                Text("Days you have been using the app")
                    .fixedSize(horizontal: false, vertical: true)
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("🔥")
                Text("\(vm.stats?.dailyStreak ?? 1)")
                Text("days")
                    .foregroundStyle(.secondary)
            }
            .redacted(reason: vm.stats == nil ? .placeholder : [])
            .cfont(.largeTitle)
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, 15)
        .background(Color.themePrimary, in: .rect(cornerRadius: cardsCornerRadious))
    }
    
    private func CashCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Cash Reward")
                    Text("You've Earned")
                        .fixedSize(horizontal: false, vertical: true)
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        vm.showingHowItWorks = true
                    }
                } label: {
                    Label("How It Works?", systemImage: "questionmark.circle")
                        .cfont(.subheadline)
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            HStack {
                Text("🤑")
                    .font(.system(size: 48))
                
                if let earningsData = earningsVM.data, let text = earningsData.balance.asCurrency() {
                    Text(text)
                        .redacted(reason: earningsVM.data?.balance == nil ? .placeholder : [])
                } else {
                    Text("$00.00")
                        .redacted(reason: .placeholder)
                }
                
                Text("USD")
                    .foregroundStyle(.secondary)
            }
            .cfont(.largeTitle)
            .fontWeight(.semibold)
            
            CButton(fullWidth: true, text: "CASH OUT", systemImage: "creditcard") {
                Task {
                    await vm.cashOut()
                }
            }
            .disabled(vm.loadingSections.contains(.cashOut) || vm.cashOutRequested || (earningsVM.data?.balance ?? 0) / 100 < 25)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.themePrimary, in: .rect(cornerRadius: cardsCornerRadious))
    }
    
    private func PublicPostsCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text("Public Posts")
                Text("Posts with Media")
                    .fixedSize(horizontal: false, vertical: true)
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            HStack {
                Text("📸")
                    .font(.system(size: 48))
                
                Text((vm.stats?.userActivityWithMediaCount ?? 1).formattedWithSuffix())
                    .cfont(.largeTitle)
                    .fontWeight(.medium)
                    .redacted(reason: vm.stats == nil ? .placeholder : [])
            }
        }
        .padding()
        .background(Color.themePrimary, in: .rect(cornerRadius: cardsCornerRadious))
    }
    
    private func UniqueReactionsCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text("Unique Reactions")
                Text("Users who reacted your posts")
                    .fixedSize(horizontal: false, vertical: true)
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            HStack {
                Text("😍")
                    .font(.system(size: 48))
                
                Text((vm.stats?.gainedUniqueReactions ?? 1).formattedWithSuffix())
                    .cfont(.largeTitle)
                    .fontWeight(.medium)
                    .redacted(reason: vm.stats == nil ? .placeholder : [])
            }
        }
        .padding()
        .background(Color.themePrimary, in: .rect(cornerRadius: cardsCornerRadious))
    }
    
    private func LeaderboardCard() -> some View {
        NavigationLink(value: AppRoute.leaderboard) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Leaderboard")
                        Text("Your Ranking")
                            .fixedSize(horizontal: false, vertical: true)
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("🏆")
                            .font(.system(size: 48))
                        
                        Text("#\(auth.currentUser?.rank ?? 1)")
                            .cfont(.largeTitle)
                            .fontWeight(.medium)
                            .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.themePrimary, in: .rect(cornerRadius: cardsCornerRadious))
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    RewardsHubView()
}
