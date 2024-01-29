//
//  EditProfileViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 18.09.2023.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreTransferable
import Combine
import UIKit

@MainActor
class EditProfileViewModel: ObservableObject {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    
    @Published var isLoading = false
    @Published var isSubmitting = false
    
    @Published var isUsernameValid: Bool = false
    @Published var usernameError: String? = nil
    
    private var cancellable = [AnyCancellable]()
    
    init() {
        $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                if value.count < 5 {
                    if value.count > 0 {
                        self?.usernameError = "Username must be at least 5 characters"
                    }
                    self?.isUsernameValid = false
                    return
                }
                self?.isLoading = true
                Task {
                    do {
                        let token = await self?.auth.getToken()
                        try await self?.apiManager.requestNoContent("/users/username-availability/\(value)", token: token)
                        self?.isUsernameValid = true
                    } catch let error as APIManager.APIError {
                        self?.isUsernameValid = false
                        switch error {
                        case .serverError(let serverError):
                            self?.usernameError = serverError.message
                        default:
                            self?.usernameError = "Unknown Error"
                        }
                    }
                    self?.isLoading = false
                }
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Profile Image
    
    @Published var isDeleting: Bool = false
    @Published private(set) var imageState: ImageState = .empty
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    enum ImageState {
        case empty
        case loading(Progress)
        case success((Image, UIImage, Data))
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    private enum UploadUseCase: String {
        case profileImage = "profileImage"
    }
    private enum UploadFileType: String {
        case jpeg = "image/jpeg"
        case png = "image/png"
    }
    private struct UploadFile {
        let name: String
        let media: UIImage
        let type: UploadFileType
    }
    
    struct ProfileImage: Transferable {
        let image: Image
        let uiImage: UIImage
        let data: Data
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ProfileImage(image: image, nsImage: nsImage, data: data)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image, uiImage: uiImage, data: data)
                
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    // MARK: - Public Methods
    
    func resetState() {
        imageState = .empty
        imageSelection = nil
    }
    
    func toggleImageDeletion() {
        if isDeleting {
            isDeleting = false
        } else {
            resetState()
            isDeleting = true
        }
    }
    
    func save() async throws {
        isSubmitting = true
        switch imageState {
        case .success:
            try? await self.uploadImage()
        default:
            break
        }
        
        struct EditUserBody: Encodable {
            let name: String?
            let username: String?
            let bio: String?
            let removeProfileImage: Bool?
        }
        
        if let token = await auth.getToken(), let uid = auth.currentUser?.id {
            do {
                let reqBody = try apiManager.createRequestBody(EditUserBody(name: self.name, username: self.username, bio: self.bio, removeProfileImage: self.isDeleting ? self.isDeleting : nil))
                let _ = try await apiManager.requestData("/users/\(uid)", method: .put, body: reqBody, token: token) as APIResponse<CurrentUserCoreData>?
            } catch {
                print(error)
            }
            isSubmitting = false
            await auth.updateUserInfo()
        }
    }
    
    // MARK: - Private Methods
    
    private func uploadFormDataBody(file: UploadFile, useCase: UploadUseCase) -> (formData: Data, boundary: String) {
        let boundary = "Boundary-\(UUID().uuidString)"
        /// line break
        let lb = "\r\n"
        var body = Data()
        
                
        body.append("\(lb)--\(boundary + lb)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"usecase\"\(lb + lb + useCase.rawValue)".data(using: .utf8)!)
        
        body.append("\(lb)--\(boundary + lb)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(file.type.rawValue.components(separatedBy: "/").first!)\"; filename=\"\(file.name)\"\(lb)".data(using: .utf8)!)
        body.append("Content-Type: \(file.type.rawValue)\(lb + lb)".data(using: .utf8)!)
        body.append(file.media.jpegData(compressionQuality: 0.5)!)
        
        print(file.media.size)
        
        body.append("\(lb)--\(boundary)--\(lb)".data(using: .utf8)!)

        return (body, boundary)
    }
    
    private func uploadImage() async throws {
        switch imageState {
        case .success(let (_, uiImage, _)):
            if let token = await auth.getToken() {
                var media: UIImage = uiImage
                if uiImage.size.width > 1024 || uiImage.size.height > 1024 {
                    media = uiImage.resized(to: CGSize(width: 1024, height: 1024))
                }
                
                let (formData, boundary) = uploadFormDataBody(file: UploadFile(name: "profileImage.jpg", media: media, type: .jpeg), useCase: .profileImage)
                try await apiManager.requestNoContent("/upload", method: .post, body: formData, token: token, contentType: .multipartFormData(boundary: boundary))
            } else {
                throw CancellationError()
            }
            
        default:
            break
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success((profileImage.image, profileImage.uiImage, profileImage.data))
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
