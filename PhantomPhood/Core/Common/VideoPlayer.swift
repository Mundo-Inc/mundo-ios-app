//
//  VideoPlayer.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/1/24.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    private let originalURL: URL
    var player: AVPlayer
    var playing: Bool
    var isMute: Bool
    
    init(url: URL, playing: Bool, isMute: Bool = false) {
        self.originalURL = url
        if playing {
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: VideoCachingManager.shared.getAsset(for: url, priority: .high)))
            self.playing = true
        } else {
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: VideoCachingManager.shared.getAsset(for: url, priority: .low)))
            self.playing = false
        }
        
        self.isMute = isMute
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = CustomPlayerViewController()
        
        context.coordinator.setupPlayerViewController(playerViewController, with: player)
        context.coordinator.addProgressBar(to: playerViewController)
        context.coordinator.setupLoadingIndicator(in: playerViewController)
        context.coordinator.setupObservers(for: player)
        
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player?.isMuted != isMute {
            uiViewController.player?.isMuted = isMute
        }
        
        if playing {
            uiViewController.player?.play()
            VideoCachingManager.shared.touchFile(at: originalURL)
        } else {
            uiViewController.player?.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        private var videoPlayerRepresentable: VideoPlayer
        private var timeObserver: Any?
        private var itemStatusObserver: NSKeyValueObservation?
        private var playbackBufferEmptyObserver: NSKeyValueObservation?
        private var playbackLikelyToKeepUpObserver: NSKeyValueObservation?
        private var statusObserver: NSKeyValueObservation?
        private var endPlaybackObserver: NSObjectProtocol?
        private var loadingIndicator: UIActivityIndicatorView?
        
        init(_ videoPlayerRepresentable: VideoPlayer) {
            self.videoPlayerRepresentable = videoPlayerRepresentable
        }
        
        deinit {
            if let timeObserver {
                videoPlayerRepresentable.player.removeTimeObserver(timeObserver)
            }
            itemStatusObserver?.invalidate()
            playbackBufferEmptyObserver?.invalidate()
            playbackLikelyToKeepUpObserver?.invalidate()
            statusObserver?.invalidate()
            if let endPlaybackObserver = endPlaybackObserver {
                NotificationCenter.default.removeObserver(endPlaybackObserver)
            }
        }
        
        func setupPlayerViewController(_ viewController: AVPlayerViewController, with player: AVPlayer) {
            viewController.player = player
            viewController.showsPlaybackControls = false
            viewController.videoGravity = .resizeAspectFill
            viewController.allowsVideoFrameAnalysis = false
            viewController.updatesNowPlayingInfoCenter = false
            
            viewController.player?.actionAtItemEnd = .none
            viewController.player?.allowsExternalPlayback = false
            viewController.player?.automaticallyWaitsToMinimizeStalling = true
            viewController.player?.audiovisualBackgroundPlaybackPolicy = .pauses
            
            viewController.view.isUserInteractionEnabled = false
            viewController.view.backgroundColor = UIColor(named: "themePrimary")
        }
        
        func addProgressBar(to viewController: AVPlayerViewController) {
            let progressBar = UIProgressView(progressViewStyle: .bar)
            progressBar.trackTintColor = UIColor.black.withAlphaComponent(0.2)
            progressBar.progressTintColor = UIColor(white: 1, alpha: 0.9)
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.addSubview(progressBar)
            
            NSLayoutConstraint.activate([
                progressBar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                progressBar.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                progressBar.heightAnchor.constraint(equalToConstant: 3)
            ])
            
            timeObserver = viewController.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak progressBar] time in
                guard let progressBar = progressBar, let currentItem = viewController.player?.currentItem else { return }
                if currentItem.duration.seconds > 0 {
                    let newProgress = Float(time.seconds / currentItem.duration.seconds)
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
                        progressBar.setProgress(newProgress, animated: true)
                    })
                }
            }
        }
        
        func setupLoadingIndicator(in viewController: AVPlayerViewController) {
            loadingIndicator = UIActivityIndicatorView(style: .medium)
            viewController.view.addSubview(loadingIndicator!)
            loadingIndicator!.center = CGPoint(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY)
            loadingIndicator!.startAnimating()
        }
        
        func setupObservers(for player: AVPlayer?) {
            playbackLikelyToKeepUpObserver = player?.currentItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .old]) { [weak self] item, change in
                DispatchQueue.main.async {
                    if item.isPlaybackLikelyToKeepUp {
                        self?.loadingIndicator?.stopAnimating()
                    } else {
                        self?.loadingIndicator?.startAnimating()
                    }
                }
            }
            
            statusObserver = player?.currentItem?.observe(\.status, options: [.new, .old]) { [weak self] item, change in
                if case .failed = item.status {
                    DispatchQueue.main.async {
                        self?.loadingIndicator?.stopAnimating()
                    }
                }
            }
            
            endPlaybackObserver = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem, queue: .main) { [weak self] _ in
                self?.videoPlayerRepresentable.player.seek(to: .zero, completionHandler: { _ in
                    self?.videoPlayerRepresentable.player.play()
                })
            }
        }
    }
}

class CustomPlayerViewController: AVPlayerViewController {
    override func viewDidDisappear(_ animated: Bool) {
        self.player?.pause()
        super.viewDidDisappear(animated)
    }
}

#Preview {
    VideoPlayer(url: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/videos/3f87a67d5336f3184d4a993ace471075.mp4")!, playing: true)
}
