//
//  DataCard.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct DataCard: View {
    let icon: String
    let iconColor: LinearGradient
    let iconBackground: LinearGradient
    let title: String
    let value: Any?
    
    
    
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(iconColor)
                .background(
                    Circle()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(iconBackground)
                )
            
            Spacer()
            
            VStack(alignment: .leading) {
                if let v = value as? String {
                    Text(v)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let v = value as? Int {
                    Text(String(v))
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ProgressView()
                }
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.leading, 8)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themePrimary)
        .clipShape(.rect(cornerRadius: 15))
    }
    
    
    
}

#Preview {
    DataCard(
        icon: "house",
        iconColor: LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom),
        iconBackground: LinearGradient(colors: [Color.blue, Color.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing),
        title: "Data",
        value: "100"
    )
}
