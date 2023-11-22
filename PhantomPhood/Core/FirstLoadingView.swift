//
//  FirstLoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FirstLoadingView: View {
    @ObservedObject var auth = Authentication.shared
    
    @State var retries: Int = 1
    
    func retry() async {
        if auth.currentUser == nil {
            withAnimation {
                retries += 1
            }
            await auth.updateUserInfo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await retry()
                }
            }
        }
    }
    
    @State var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            CircleLabelView(text: "BY FOODIES ● FOR FOODIES ● ")
                .frame(width: 200, height: 200)
                .foregroundStyle(Color.accentColor)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            if retries == 2 {
                Text("Weird, It should not take this long")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else if retries >= 3 {
                Button {
                    auth.signout()
                } label: {
                    Label(
                        title: { Text("Log Out") },
                        icon: { Image(systemName: "rectangle.portrait.and.arrow.right") }
                    )
                }
                .buttonStyle(.bordered)
                
                Text("Looks like we hit a snag :(\nOur apologies for the hiccup. Remember, we're still fine-tuning things in Beta mode. Try the *classic tech trick*: log out and sign back in. It's surprising how often that works wonders!")
                    .padding(.horizontal)
            }
        }
        .font(.custom(style: .subheadline))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await retry()
                }
            }
        }
    }
}

#Preview {
    FirstLoadingView()
}
