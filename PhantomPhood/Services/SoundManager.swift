//
//  SoundManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/22/24.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    private let audioQueue = DispatchQueue(label: "audioQueue")
    
    private init() {
        configureAudioSession()
    }
    
    func playSound(_ sound: Sound) {
        audioQueue.async {
            self.setupAndPlay(sound: sound)
        }
    }
    
    private func setupAndPlay(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else { return }
        
        do {
            if self.audioPlayer == nil || self.audioPlayer?.url != url {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            // Ensure audioPlayer is not nil and prepare to play to reduce latency
            guard self.audioPlayer?.prepareToPlay() ?? false else { return }
            DispatchQueue.main.async {
                self.audioPlayer?.play()
            }
        } catch {
            print(error)
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session. Error: \(error)")
        }
    }
}

// MARK: - Sound Definition

extension SoundManager {
    enum Sound: String {
        case coin
        
        var fileName: String {
            switch self {
            case .coin:
                return "Coin"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .coin:
                return "mp3"
            }
        }
    }
}
