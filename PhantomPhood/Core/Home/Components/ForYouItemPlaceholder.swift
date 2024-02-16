//
//  ForYouItemPlaceholder.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct ForYouItemPlaceholder: View {
    let parentGeometry: GeometryProxy?
    
    var body: some View {
        ZStack {
            Color.themePrimary
            
            Rectangle()
                .foregroundStyle(.clear)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - (parentGeometry?.safeAreaInsets.bottom ?? 0))
            
            LinearGradient(colors: [.black.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
            
            ZStack {
                VStack(spacing: 0) {
                        HStack {
                            VStack(spacing: -15) {
                                ProfileImage("", size: 50)
                                
                                LevelView(level: 20)
                                    .frame(width: 24, height: 30)
                                    .clipShape(.rect(cornerRadius: 5))
                            }
                            
                            VStack {
                                    Text("User Name")
                                        .font(.custom(style: .headline))
                                        .frame(height: 18)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                
                                HStack {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        
                                        Text("Place Name")
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text("2h")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .background(Material.ultraThin.opacity(0.7))
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        VStack(spacing: 5) {
                            HStack {
                                StarRating(score: 5)
                                
                                Text("(5/5)")
                                    .font(.custom(style: .headline))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            
                            Text("This is a placeholder review content. This is a placeholder review content. This is a placeholder review content.")
                                .lineLimit(5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .padding(.trailing, 52)
                        .padding(.trailing)
                        .frame(maxWidth: .infinity)
                        .background {
                            LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.4), .black.opacity(0.5), .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                .allowsHitTesting(false)
                        }
                }
                .padding(.top)
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Spacer()
                        Group {
                            Text("😍")
                            
                            Text("😍")
                        }
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .stroke(Color.black.opacity(0.1), lineWidth: 4)
                        }
                        .frame(width: 70, height: 34)
                        .clipShape(Capsule())
                        
                        Capsule()
                            .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                            .foregroundStyle(.ultraThinMaterial)
                            .frame(width: 70, height: 34)
                            .overlay {
                                Image(.addReaction)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 22)
                                    .foregroundStyle(.white)
                            }
                        
                        Capsule()
                            .background(Capsule().foregroundStyle(.white.opacity(0.2)))
                            .foregroundStyle(.ultraThinMaterial)
                            .frame(width: 70, height: 34)
                            .overlay {
                                Image(systemName: "bubble.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 22)
                                    .foregroundStyle(.white)
                            }
                        .padding(.horizontal, 5)
                    }
                    .frame(width: 52)
                    .padding(.trailing)
                    .padding(.vertical)
                    .padding(.bottom, 80)
                }
            }
            .font(.custom(style: .body))
            .padding(.top, parentGeometry?.safeAreaInsets.top)
        }
        .frame(maxWidth: .infinity)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    ForYouItemPlaceholder(parentGeometry: nil)
}
