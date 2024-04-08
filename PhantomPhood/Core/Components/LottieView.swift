//
//  LottieView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12.09.2023.
//

import SwiftUI
import Lottie

enum LottieFiles: String {
    case welcome = "Welcome"
    case processing = "Processing"
    case drinkingCoffee = "DrinkingCoffee"
    case reviews = "Reviews"
    case friends = "Friends"
    case rewards = "Rewards"
    case rewardLightEffect = "RewardLightEffect"
    case wanderingGhost = "WanderingGhost"
}

struct LottieView: UIViewRepresentable {
    private let animationView = LottieAnimationView()
    let file: String
    var loop: Bool? = nil
    
    init(file: LottieFiles, loop: Bool? = nil) {
        self.file = file.rawValue
        self.loop = loop
    }
    init(fileName: String, loop: Bool? = nil) {
        self.file = fileName
        self.loop = loop
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        
        let animation = LottieAnimation.named(file)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        if let _ = loop {
            animationView.loopMode = .loop
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    }
    
}

#Preview {
    LottieView(file: .welcome)
}
