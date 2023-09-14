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
}

struct LottieView: UIViewRepresentable {
    private let animationView = LottieAnimationView()
    let file: LottieFiles
    var loop: Bool? = nil
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        
        let animation = LottieAnimation.named(file.rawValue)
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

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(file: .welcome)
    }
}
