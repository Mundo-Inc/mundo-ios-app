//
//  CameraVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/27/24.
//

import Foundation
import AVFoundation

@MainActor
final class CameraVM: ObservableObject {
    @Published var captureType: CaptureType = .photo
    
    enum CaptureType: String, CaseIterable {
        case photo = "Photo"
        case video = "Video"
    }
}

protocol HasCaptureSession: ObservableObject {
    var session: AVCaptureSession { get }
}
