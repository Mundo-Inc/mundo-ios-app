//
//  PrizeItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/15/24.
//

import SwiftUI

struct PrizeItem: View {
    @ObservedObject var vm: RewardsHubVM
    let data: Prize
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 135, height: 180)
                    .matchedGeometryEffect(id: "\(data.id)-bg", in: namespace)
                
                ImageLoader(data.thumbnail, contentMode: .fill) { progress in
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(maxWidth: 150)
                        .overlay {
                            ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.horizontal)
                        }
                }
                .matchedGeometryEffect(id: "\(data.id)-img", in: namespace)
                .frame(width: 135, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                if data.isRedeemed {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.black.opacity(0.75))
                    
                    Text("Redeemed".uppercased())
                        .font(.custom(style: .headline))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            
            Text(data.title)
                .lineLimit(2, reservesSpace: true)
                .font(.custom(style: .body))
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 5) {
                Image(.phantomCoin)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text(data.amount.formattedWithSuffix())
                    .font(.custom(style: .headline))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 135)
        .onTapGesture {
            if !data.isRedeemed && vm.selectedPrize == nil {
                withAnimation {
                    vm.selectedPrize = data
                }
            }
        }
    }
    
    static var placeholder: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.themeBorder.opacity(0.8))
                .frame(width: 135, height: 180)
            
            Text("Prize Title")
                .font(.custom(style: .headline))
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            HStack(spacing: 5) {
                Text("1000")
                    .font(.custom(style: .headline))
                    .foregroundStyle(Color.secondary)
                Image(.phantomCoin)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
        .frame(width: 135)
        .redacted(reason: .placeholder)
    }
}
