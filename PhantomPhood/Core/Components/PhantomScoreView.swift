//
//  PhantomScoreView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/2/23.
//

import SwiftUI

struct PhantomScoreView: View {
    let score: Double?
    let isLoading: Bool
    
    init(score: Double?, isLoading: Bool = false) {
        self.score = score
        self.isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            Color(.ratingsBG)
                .shadow(color: Color.black.opacity(0.15), radius: 8)
                .clipShape(.rect(cornerRadius: 15))
                
            
            HStack {
                ZStack {
                    Circle()
                        .trim(from: 0.3, to: 1)
                        .stroke(Color.gray, lineWidth: 6)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(35))
                        
                    
                    Group {
                        if let score = score, !isLoading {
                            Text(String(format: "%.1f", score))
                        } else if !isLoading {
                            Text("TBD")
                        } else {
                            Text("100")
                        }
                    }
                    .font(.custom(style: .title2))
                    .bold()
                    .offset(y: -4)
                    .redacted(reason: isLoading ? .placeholder : [])
                    
                    Circle()
                        .trim(from: 0.3, to: (score != nil && !isLoading) ? 0.3 + (0.7 * (score! / 100)) : 0.3)
                        .stroke(Color.accentColor, lineWidth: 6)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(35))
                        .animation(.easeInOut(duration: 1), value: score)
                    
                    VStack {
                        ZStack {
                            Circle()
                                .overlay {
                                    Color.black.opacity(0.2)
                                }
                                .foregroundColor(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: Color.accentColor,radius: 3)
                            
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: 16, height: 16)
                        .offset(y: -8)
                        
                        
                        Spacer()
                    }
                    .frame(width: 80, height: 80)
                    .rotationEffect((score != nil && !isLoading) ? .degrees((-135 + 250 * (score! / 100))) : .degrees(-135))
                    .animation(.easeInOut(duration: 1), value: score)
                }
                .frame(height: 70)
                .offset(y: 15)
                
                Spacer()
                
                Image("Phantom")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(y: 10)
                
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .clipped()
        }
        .frame(height: 70)
        
    }
}

#Preview {
    VStack {
        HStack {
            PhantomScoreView(score: nil, isLoading: true)
            PhantomScoreView(score: nil, isLoading: false)
        }
        HStack {
            PhantomScoreView(score: 76.5523, isLoading: true)
            PhantomScoreView(score: 100, isLoading: false)
        }
    }
}
