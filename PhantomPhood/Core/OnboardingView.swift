//
//  OnboardingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/22/24.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var vm: OnboardingVM
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    func handleNext() {
        switch vm.section {
        case .journey:
            withAnimation(.easeOut(duration: 1)) {
                vm.backgroundShift = mainWindowSize.height / 2.2
                vm.section = .share
            }
        case .share:
            withAnimation(.easeOut(duration: 1)) {
                vm.backgroundShift = mainWindowSize.height / 1.9
                vm.section = .connect
            }
        case .connect:
            withAnimation(.easeOut(duration: 1)) {
                vm.backgroundShift = mainWindowSize.height / 1.5
                vm.section = .rewards
            }
        case .rewards:
            vm.done()
        }
        
        for i in 0...30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * i / 30) * 0.03) {
                HapticManager.shared.impact(style: .soft)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(vm.backgroundShift == 0 ? 1 : 0)
                .ignoresSafeArea()
                .onAppear {
                    for i in 0...30 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * i / 30) * 0.03) {
                            HapticManager.shared.impact(style: .soft)
                        }
                    }
                    
                    withAnimation(.bouncy(duration: 1)) {
                        vm.isShowing = true
                    }
                }
            
            Rectangle()
                .fill(.linearGradient(.init(colors: [
                    Color(hue: 202 / 360, saturation: 1, brightness: 0.5),
                    Color(hue: 340 / 360, saturation: 1, brightness: 0.43),
                    Color(hue: 284 / 360, saturation: 1, brightness: 0.51),
                ]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .mask(canvas)
                .ignoresSafeArea()
            
            VStack {
                Image(.fullPhantom)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .padding(.top, mainWindowSize.height * 0.07)
                
                Spacer()
                
                if vm.isShowing {
                    Group {
                        switch vm.section {
                        case .journey:
                            Text("Capture your\n*experiences* with\nyour friends.")
                                .shadow(radius: 20)
                                .font(.custom(style: .title))
                                .fontWeight(.bold)
                        case .share:
                            VStack(spacing: 40) {
                                Text("Share your taste")
                                    .shadow(radius: 20)
                                    .font(.custom(style: .title))
                                    .fontWeight(.bold)
                                
                                Text("Write reviews and post delicious images and videos. Share your experiences with friends and family and inspire foodies like you around the world.")
                                    .multilineTextAlignment(.leading)
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        case .connect:
                            VStack(spacing: 40) {
                                Text("Connect with friends")
                                    .shadow(radius: 20)
                                    .font(.custom(style: .title))
                                    .fontWeight(.bold)
                                
                                Text("See where your friends are dining and what they recommend. Connect over shared tastes and plan your next food adventure together.")
                                    .multilineTextAlignment(.leading)
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        case .rewards:
                            VStack(spacing: 30) {
                                Text("Earn tasty rewards")
                                    .shadow(radius: 20)
                                    .font(.custom(style: .title))
                                    .fontWeight(.bold)
                                
                                Text("Join our Rewards Hub! Earn points for every check-in and review, and redeem them for exciting prizes. Turn your food explorations into rewarding experiences.")
                                    .multilineTextAlignment(.leading)
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .transition(
                        AnyTransition.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).animation(.bouncy(duration: 1)),
                            removal: .move(edge: .top).combined(with: .opacity).animation(.bouncy(duration: 1))
                        )
                    )
                }
                
                Spacer()
                
                if vm.isShowing {
                    Button {
                        handleNext()
                    } label: {
                        Text("Let's Go")
                            .foregroundStyle(Color.primary)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.accentColor.opacity(vm.backgroundShift == 0 ? 0.8 : 0.6), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    .transition(AnyTransition.fade.animation(.bouncy(duration: 0.5).delay(1)))
                } else {
                    Color.clear
                        .frame(height: 52)
                }
                
                if vm.section == .journey {
                    Text("An app about your moments")
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                        .frame(height: 52)
                } else if vm.section != .rewards {
                    Button {
                        vm.done()
                    } label: {
                        Text("Skip")
                            .foregroundStyle(Color.primary)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .padding(.horizontal)
                    .transition(AnyTransition.fade.animation(.bouncy(duration: 0.5)))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
    
    private var canvas: some View {
        Canvas { context, size in
            context.addFilter(.blur(radius: 35))
            context.addFilter(.alphaThreshold(min: 0.8))
            context.addFilter(.blur(radius: 15))
            context.drawLayer { ctx in
                if let symbol = ctx.resolveSymbol(id: 1) {
                    ctx.draw(symbol, at: .zero)
                }
            }
        } symbols: {
            TimelineView(.animation()) { timeline in
                let value = (timeline.date.timeIntervalSince1970 * 30).rounded(toPlaces: 0)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .rotationEffect(.degrees(-value.truncatingRemainder(dividingBy: 360)))
                        .offset(y: -vm.backgroundShift / 2)
                        .frame(width: 650, height: 650)
                    
                    RoundedRectangle(cornerRadius: 100)
                        .rotationEffect(.degrees(value.truncatingRemainder(dividingBy: 360)))
                        .offset(y: -vm.backgroundShift / 2)
                        .frame(width: 600, height: 600)
                        .offset(CGSize(width: 0, height: abs(100 - value.truncatingRemainder(dividingBy: 200))))
                    
                    Capsule()
                        .rotationEffect(.degrees(value.truncatingRemainder(dividingBy: 360)))
                        .offset(y: vm.backgroundShift / 3)
                        .frame(width: 450, height: 550)
                        .offset(x: mainWindowSize.width, y: mainWindowSize.height * 0.5)
                    
                    Capsule()
                        .rotationEffect(.degrees(value.truncatingRemainder(dividingBy: 360)))
                        .offset(y: -vm.backgroundShift / 3)
                        .frame(width: 550, height: 400)
                        .offset(x: 100, y: mainWindowSize.height * 0.8)
                }
                .offset(y: -vm.backgroundShift)
            }
            .tag(1)
        }
    }
}

#Preview {
    OnboardingView(vm: OnboardingVM())
}
