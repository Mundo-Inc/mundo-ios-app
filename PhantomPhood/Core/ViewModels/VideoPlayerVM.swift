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
}
