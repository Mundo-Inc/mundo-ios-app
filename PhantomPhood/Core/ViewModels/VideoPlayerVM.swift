//
//  VideoPlayerVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/27/23.
//

import Foundation
import SwiftUI

@MainActor
final class VideoPlayerVM: ObservableObject {
    static let shared = VideoPlayerVM()
    private init () {}
    
    @Published var isMute = false
    @Published var playId: String? = nil
    
    func playBinding(for videoId: String) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                return self.playId == videoId
            },
            set: { isPlaying in
                // Update the playId only if necessary to prevent unnecessary view refreshes
                if isPlaying && self.playId != videoId {
                    self.playId = videoId
                } else if !isPlaying && self.playId == videoId {
                    self.playId = nil
                }
            }
        )
    }
}
