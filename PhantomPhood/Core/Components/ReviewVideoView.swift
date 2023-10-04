//
//  ReviewVideoView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/27/23.
//

import SwiftUI
import AVKit

struct ReviewVideoView: View {
    let url: String
    let mute: Bool
    @State private var player = AVPlayer()
    
    init(url: String, mute: Bool = false) {
        self.url = url
        self.mute = mute
    }
        
    var body: some View {
        if let theURL = URL(string: url) {
            PlayerViewController(url: theURL, mute: mute)
        }
    }
}

struct PlayerViewController: UIViewControllerRepresentable {
    let url: URL
    let mute: Bool
    
    init(url: URL, mute: Bool = false) {
        self.url = url
        self.mute = mute
    }
    
    private var player: AVPlayer {
       AVPlayer(url: url)
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        configureAudioSession()
        
        let controller = AVPlayerViewController()
        controller.player = player
        controller.player?.isMuted = mute
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        controller.allowsVideoFrameAnalysis = false
        controller.player?.automaticallyWaitsToMinimizeStalling = false
        
        DispatchQueue.main.async {
            controller.player?.play()
        }
                        
        return controller
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.player?.isMuted = mute
    }
}

#Preview {
    ZStack {
        Color.green
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        ReviewVideoView(url: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645e7f843abeb74ee6248ced/videos/2a667b01b413fd08fd00a60b2f5ba3e1.mp4", mute: true).frame(width: 200, height: 200)
            
            
    }
    .frame(width: 200, height: 200)
}
