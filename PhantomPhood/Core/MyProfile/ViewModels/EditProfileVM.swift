//
//  EditProfileViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 18.09.2023.
//

import Foundation
import SwiftUI
import Combine

class EditProfileVM: ObservableObject, LoadingSections {
    private let checksDM = ChecksDM()
    private let userProfileDM = UserProfileDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    
    @Published private(set) var isUsernameValid: Bool = false
    @Published private(set) var usernameError: String? = nil
    
    @Published var isDeleting: Bool = false
    
    @Published var presentedSheet: Sheets? = nil
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                Task {
                    await self.handleUsernameChange(value)
                }
            }
            .store(in: &cancellable)
    }
            
    // MARK: - Public Methods
        
    @MainActor
    func save(image: PickerMediaItem?) async {
        guard !loadingSections.contains(.submittingChanges) else { return }
        
        setLoadingState(.submittingChanges, to: true)
        
        defer {
            setLoadingState(.submittingChanges, to: false)
        }
        
        do {
            if let image, case .loaded(let mediaData) = image.state, case .image(let uiImage) = mediaData {
                do {
                    try await resizeAndUploadImage(uiImage: uiImage)
                } catch {
                    presentErrorToast(error)
                }
            }
            
            try await userProfileDM.editProfileInfo(changes: .init(name: self.name, username: self.username, bio: self.bio, removeProfileImage: self.isDeleting ? self.isDeleting : nil))
        } catch {
            presentErrorToast(error)
        }
        
        await Authentication.shared.updateUserInfo()
    }
    
    // MARK: - Private Methods
    
    private func resizeAndUploadImage(uiImage: UIImage) async throws {
        guard let resizedIamge = ImageHelper.resize(uiImage: uiImage, targetSize: CGSize(width: 512, height: 512)),
              var compressedData = ImageHelper.compress(uiImage: resizedIamge, compressionQuality: 0.9)
        else {
            throw CancellationError()
        }
        
        if compressedData.count / 1024 > 250 {
            if let data = ImageHelper.compress(uiImage: resizedIamge, compressionQuality: compressedData.count / 1024 > 500 ? 0.6 : 0.75) {
                compressedData = data
            }
        }
        
        let _ = try await UploadManager.shared.uploadMedia(media: .image(compressedData), usecase: .profileImage)
    }
    
    private func handleUsernameChange(_ value: String) async {
        guard value.count >= 5 else {
            await MainActor.run {
                if value.count > 0 {
                    self.usernameError = "Username must be at least 5 characters"
                }
                self.isUsernameValid = false
            }
            
            return
        }
        
        setLoadingState(.checkingUsername, to: true)
        
        defer {
            setLoadingState(.checkingUsername, to: false)
        }
        
        do {
            try await checksDM.checkUsername(value)
            await MainActor.run {
                self.isUsernameValid = true
                self.usernameError = nil
            }
        } catch {
            await MainActor.run {
                self.isUsernameValid = false
                self.usernameError = getErrorMessage(error)
            }
        }
    }
    
    enum LoadingSection: Hashable {
        case submittingChanges
        case checkingUsername
    }
    
    enum Sheets {
        case photosPicker
    }
}
