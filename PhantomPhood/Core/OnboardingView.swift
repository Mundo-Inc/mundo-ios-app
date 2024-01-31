//
//  OnboardingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/31/24.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    Spacer()
                    
                    Group {
                        switch vm.selection {
                        case 0:
                            LottieView(file: .drinkingCoffee, loop: true)
                                .frame(maxHeight: proxy.size.height * 0.35)
                        case 1:
                            LottieView(file: .reviews, loop: true)
                                .frame(maxHeight: proxy.size.height * 0.35)
                        case 2:
                            LottieView(file: .friends, loop: true)
                                .frame(maxHeight: proxy.size.height * 0.35)
                        case 3:
                            ZStack {
                                LottieView(file: .rewardLightEffect, loop: true)
                                    .frame(maxHeight: proxy.size.height * 0.45)
                                    .opacity(0.5)
                                LottieView(file: .rewards)
                                    .frame(maxHeight: proxy.size.height * 0.35)
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .transition(AnyTransition.slide.animation(.bouncy))
                    .animation(.bouncy, value: vm.selection)
                    .shadow(color: Color.white.opacity(0.2), radius: 20)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding()
                
                TabView(selection: $vm.selection) {
                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Capture Your Foodie Journey")
                                .font(.custom(style: .title2))
                                .fontWeight(.bold)
                            
                            Text("Check-in and share photos and videos of your culinary adventures to capture the essence of each dining experience.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.custom(style: .body))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .tag(0)
                    
                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Share Your Taste")
                                .font(.custom(style: .title2))
                                .fontWeight(.bold)
                            
                            Text("Write reviews and post delicious images and videos. Share your experiences with friends and family and inspire foodies like you around the world.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.custom(style: .body))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .tag(1)
                    
                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Connect with Friends")
                                .font(.custom(style: .title2))
                                .fontWeight(.bold)
                            
                            Text("See where your friends are dining and what they recommend. Connect over shared tastes and plan your next food adventure together.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.custom(style: .body))
                        }

                        Spacer()
                    }
                    .padding()
                    .tag(2)
                    
                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Earn Tasty Rewards")
                                .font(.custom(style: .title2))
                                .fontWeight(.bold)
                            
                            Text("Join our Rewards Hub! Earn points for every check-in and review, and redeem them for exciting prizes. Turn your food explorations into rewarding experiences.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.custom(style: .body))
                        }
                        
                        Spacer()
                        
                        Button {
                            vm.done()
                        } label: {
                            Text("Get Started")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .tag(3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .tabViewStyle(.page)
            }
            .preferredColorScheme(.dark)
            .background(Color.themeBG)
        }
    }
}

#Preview {
    OnboardingView(vm: OnboardingVM())
}
