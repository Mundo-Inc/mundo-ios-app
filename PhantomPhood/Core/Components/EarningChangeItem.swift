//
//  EarningChangeItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/25/24.
//

import SwiftUI

struct EarningChangeItem: View {
    private let item: EarningsVM.ChangeEntity
    
    init(_ item: EarningsVM.ChangeEntity) {
        self.item = item
    }
    
    var body: some View {
        VStack(spacing: 25) {
            if let text = item.amount.asCurrency() {
                Group {
                    if item.amount > 0 {
                        Text("+" + text)
                            .foregroundStyle(Color.green)
                    } else if item.amount < 0 {
                        Text(text)
                            .foregroundStyle(Color.red)
                    }
                }
                .cfont(.title)
            }
            
            if let title = item.title {
                Text(title)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
        .shadow(radius: 10)
    }
}

#Preview {
    EarningChangeItem(.init(title: "Check In", amount: 0.2))
}
