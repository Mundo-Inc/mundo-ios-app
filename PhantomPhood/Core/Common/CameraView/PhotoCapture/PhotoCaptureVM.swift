//
//  PhotoCaptureVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/27/24.
//

import Foundation
import AVFoundation

final class PhotoCaptureVM: NSObject, ObservableObject, HasCaptureSession {
    var session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "com.phantomphood.AVCaptureSession")
    private var status = Status.unconfigured
    private var photoOutput = AVCapturePhotoOutput()
    
    @Published var error: CameraError?
    
    @Published var isTaken = false
    @Published var isLoading = false
    @Published var aspectRatio: CMVideoDimensions? = nil
    @Published var currentCameraType: AVCaptureDevice.Position = .front
    
    @Published var picData: Data? = nil
    
    func start() {
        checkPermissions()
        
        guard self.error == nil, self.status == .unconfigured else { return }
        
        sessionQueue.async {
            self.configureCaptureSession(cameraType: .front)
        }
    }
    
    func toggleCamera() {
        let newCameraType: AVCaptureDevice.Position = self.currentCameraType == .back ? .front : .back
        
        sessionQueue.async {
            self.changeConfiguration(toCameraType: newCameraType)
        }
    }
    
    func capturePhoto() {
        DispatchQueue.main.async {
            self.picData = nil
            self.isLoading = true
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func retake() {
        guard isTaken else { return }
        
        DispatchQueue.main.async {
            self.isTaken = false
        }
    }
    
    // MARK: - Private Methods
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    self.checkPermissions()
                } else {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    private func configureCaptureSession(cameraType: AVCaptureDevice.Position) {
        guard status == .unconfigured else { return }
        
        if session.isRunning {
            session.stopRunning()
        }
        
        self.session.beginConfiguration()
        
        defer {
            self.session.commitConfiguration()
            
            self.session.startRunning()
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraType) else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        
        DispatchQueue.main.async {
            self.currentCameraType = cameraType
            self.aspectRatio = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        
        if self.session.canAddOutput(photoOutput) {
            self.session.addOutput(photoOutput)
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }
        
        status = .configured
    }
    
    private func changeConfiguration(toCameraType cameraType: AVCaptureDevice.Position) {
        guard status == .configured else { return }
        
        if session.isRunning {
            session.stopRunning()
        }
        
        self.session.beginConfiguration()
        
        defer {
            self.session.commitConfiguration()
            
            self.session.startRunning()
        }
        
        // Clear existing inputs
        self.session.inputs.forEach { input in
            self.session.removeInput(input)
        }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraType) else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        
        DispatchQueue.main.async {
            self.currentCameraType = cameraType
            self.aspectRatio = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        
        if !self.session.outputs.contains(where: { $0 is AVCapturePhotoOutput }) {
            if self.session.canAddOutput(photoOutput) {
                self.session.addOutput(photoOutput)
            } else {
                set(error: .cannotAddOutput)
                status = .failed
                return
            }
        }
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

extension PhotoCaptureVM: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print(error)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isTaken = true
            self?.picData = data
        }
    }
}


extension PhotoCaptureVM {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
}
