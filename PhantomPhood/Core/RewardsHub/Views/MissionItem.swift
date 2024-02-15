//
//  MissionItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/15/24.
//

import SwiftUI

struct MissionItem: View {
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

extension MissionItem {
    static var placeholder: some View {
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

//#Preview {
//    MissionItem()
//}
