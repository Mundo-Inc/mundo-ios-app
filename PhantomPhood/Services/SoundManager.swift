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
    
    public func playSound(_ sound: Sound) {
        audioQueue.async {
            self.setupAndPlay(sound: sound)
        }
    }
    
    public func prepare(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else { return }
        
        if let audioPlayer, audioPlayer.url == url {
            audioPlayer.prepareToPlay()
        } else {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                
                self.audioPlayer?.prepareToPlay()
            } catch {
                presentErrorToast(error, silent: true)
            }
        }
    }
    
    private func setupAndPlay(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else { return }
        
        if let audioPlayer, audioPlayer.url == url {
            DispatchQueue.main.async {
                audioPlayer.play()
            }
        } else {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                
                DispatchQueue.main.async {
                    self.audioPlayer?.play()
                }
            } catch {
                presentErrorToast(error, silent: true)
            }
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            presentErrorToast(error, debug: "Failed to configure audio session", silent: true)
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
