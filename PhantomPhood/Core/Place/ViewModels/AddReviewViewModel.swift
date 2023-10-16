//
//  AddReviewViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/9/23.
//

import Foundation
import PhotosUI
import CoreTransferable
import SwiftUI

@MainActor
class AddReviewViewModel: ObservableObject {
    enum Steps {
        case recommendation
        case scores
        case review
    }
    
    private let apiManager = APIManager()
    private let auth = Authentication.shared
    private let toastViewModel = ToastViewModel.shared
    
    @Published var step: Steps = .recommendation
    
    @Published var isRecommended: Bool? = nil
    @Published var overallScore: Int? = nil
    @Published var foodQuality: Int? = nil
    @Published var drinkQuality: Int? = nil
    @Published var service: Int? = nil
    @Published var atmosphere: Int? = nil
    
    @Published var isPublic = true
    @Published var reviewContent = ""
    
    @Published var isSubmitting = false

    var haveAnyScore: Bool {
        overallScore != nil || foodQuality != nil || drinkQuality != nil || service != nil || atmosphere != nil
    }
    
    func submit(place: String) async {
        self.isSubmitting = true
        
        do {
            try await uploadMedias()
            
            guard let token = auth.token else {
                throw CancellationError()
            }
            
            struct RequestBody: Encodable {
                let place: String
                let scores: ScoresBody
                let content: String
                let recommend: Bool?
                let images: [MediaIds]
                let videos: [MediaIds]
                
                struct ScoresBody: Encodable {
                    let overall: Int?
                    let drinkQuality: Int?
                    let foodQuality: Int?
                    let service: Int?
                    let atmosphere: Int?
                    let value: Int?
                }
            }
            
            let body = try apiManager.createRequestBody(RequestBody(place: place, scores: .init(overall: overallScore, drinkQuality: drinkQuality, foodQuality: foodQuality, service: service, atmosphere: atmosphere, value: nil), content: reviewContent, recommend: isRecommended, images: imageUploads, videos: videoUploads))
            
            let _ = try await apiManager.requestNoContent("/reviews", method: .post, body: body, token: token)
            
            toastViewModel.toast(.init(type: .success, title: "Review", message: "We got your review 🙌🏻 Thanks!"))
        } catch {
            print(error)
            toastViewModel.toast(.init(type: .error, title: "Review", message: "Error sending review"))
        }
        
        self.isSubmitting = false
    }
    
    struct MediaIds: Encodable {
        let uploadId: String
        let caption: String
    }
    @Published var imageUploads: [MediaIds] = []
    @Published var videoUploads: [MediaIds] = []
    private enum UploadUseCase: String {
        case placeReview = "placeReview"
    }
    private enum UploadFileType: String {
        case image = "image/jpeg"
        case video = "video/mp4"
    }
    private struct UploadFile {
        let name: String
        let data: Data
        let type: UploadFileType
    }
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
        body.append(file.data)
                
        body.append("\(lb)--\(boundary)--\(lb)".data(using: .utf8)!)

        return (body, boundary)
    }
    private func uploadMedias() async throws {
        struct APIResponse: Decodable {
            let success: Bool
            let data: ResponseData
            
            struct ResponseData: Decodable, Identifiable {
                let _id: String
                let user: String
                let key: String
                let src: String
                let type: String
                let usecase: String
                let createdAt: String
                
                var id: String {
                    self._id
                }
            }
        }

        if let token = auth.token {
            for media in mediaItemsState {
                switch media.state {
                case .successImage(let uiImage):
                    if media.isCompressed {
                        var d: UIImage = uiImage
                        if uiImage.size.width > 1024 || uiImage.size.height > 1024 {
                            d = uiImage.resized(to: CGSize(width: 1024, height: 1024))
                        }
                        
                        do {
                            if let data = d.jpegData(compressionQuality: 0.8) {
                                let (formData, boundary) = uploadFormDataBody(file: UploadFile(name: media.id + ".jpg", data: data, type: .image), useCase: .placeReview)
                                let (resData, _) = try await apiManager.request("/upload", method: .post, body: formData, token: token, contentType: .multipartFormData(boundary: boundary)) as (APIResponse?, HTTPURLResponse)
                                if let resData {
                                    self.imageUploads.append(.init(uploadId: resData.data.id, caption: ""))
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                case .successMovie(let movie):
                    if media.isCompressed {
                        do {
                            let data = try Data(contentsOf: movie.url)
                            
                            let (formData, boundary) = uploadFormDataBody(file: UploadFile(name: media.id + ".mp4", data: data, type: .video), useCase: .placeReview)
                            let (resData, _) = try await apiManager.request("/upload", method: .post, body: formData, token: token, contentType: .multipartFormData(boundary: boundary)) as (APIResponse?, HTTPURLResponse)
                            
                            if let resData {
                                self.videoUploads.append(.init(uploadId: resData.data.id, caption: ""))
                            }
                        } catch {
                            print(error)
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    @Published var mediaItemsState: [MediaItem] = []
    @Published var mediaSelection: [PhotosPickerItem] = [] {
        didSet {
            mediaItemsState.removeAll()
            
            for item in mediaSelection {
                let id = UUID().uuidString
                let progress = loadTransferable(from: item, id: id)
                self.mediaItemsState.append(.init(id: id, state: .loading(progress: progress), isCompressed: false))
            }
        }
    }
    
    enum MediaState {
        case empty
        case loading(Progress)
        case videoSuccess(Movie)
        case imageSuccess(Image)
        case failure(Error)
    }
    
    enum MediaType {
        case image
        case png
        case video
    }
    
    func loadTransferable(from pickerItem: PhotosPickerItem, id: String) -> Progress {
        let videoTypes: [UTType] = [.mpeg4Movie, .movie, .video, .quickTimeMovie, .appleProtectedMPEG4Video, .avi, .mpeg, .mpeg2Video]
        
        if pickerItem.supportedContentTypes.contains(where: { item in
            return videoTypes.contains(item)
        }) {
            return pickerItem.loadTransferable(type: Movie.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        self.mediaItemsState = self.mediaItemsState.map({ item in
                            if item.id == id {
                                return item.newState(state: .successMovie(data: data), isCompressed: false)
                            }
                            return item
                        })
                    case .success(nil):
                        break
    //                    self.mediaItemsState.removeAll { item in
    //                        item.id == id
    //                    }
                    case .failure(let error):
                        self.mediaItemsState = self.mediaItemsState.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error: error), isCompressed: false)
                            }
                            return item
                        })
                    }
                }
            }
        } else {
            return pickerItem.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        self.mediaItemsState = self.mediaItemsState.map({ item in
                            if item.id == id {
                                if let uiImage = UIImage(data: data) {
                                    return item.newState(state: .successImage(data: uiImage), isCompressed: false)
                                }
                            }
                            return item
                        })
                    case .success(nil):
                        break
    //                    self.mediaItemsState.removeAll { item in
    //                        item.id == id
    //                    }
                    case .failure(let error):
                        self.mediaItemsState = self.mediaItemsState.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error: error), isCompressed: false)
                            }
                            return item
                        })
                    }
                }
            }
        }
    }
    
    var compressVideoNo = 0
    func compress(item: MediaItem) {
        switch item.state {
        case .successImage(let uiImage):
            let data = uiImage.jpegData(compressionQuality: 0.6)
            if let data, let theImage = UIImage(data: data) {
                self.mediaItemsState = self.mediaItemsState.map({ i in
                    if item.id == i.id {
                        return item.newState(state: .successImage(data: theImage), isCompressed: true)
                    } else {
                        return i
                    }
                })
            }
        case .successMovie(let movie):
            compressVideoNo += 1
            let asset = AVAsset(url: movie.url)
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let compressedVideoURL = documentsPath.appendingPathComponent("compressedVideo\(compressVideoNo).mp4")
            
            if FileManager.default.fileExists(atPath: compressedVideoURL.path) {
                try? FileManager.default.removeItem(at: compressedVideoURL)
            }
            
            exportSession?.outputURL = compressedVideoURL
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.exportAsynchronously {
                DispatchQueue.main.async {
                    self.mediaItemsState = self.mediaItemsState.map({ i in
                        if item.id == i.id {
                            return item.newState(state: .successMovie(data: Movie(url: compressedVideoURL)), isCompressed: true)
                        }
                        return i
                    })
                }
            }
        default: break
        }
    }
}


struct MediaItem: Identifiable {
    let id: String
    var state: MediaItemState
    var isCompressed: Bool
    
    func newState(state newState: MediaItemState, isCompressed: Bool) -> MediaItem {
        return MediaItem(id: self.id, state: newState, isCompressed: isCompressed)
    }
}
enum MediaItemState {
    case empty
    case successImage(data: UIImage)
    case successMovie(data: Movie)
    case loading(progress: Progress)
    case failure(error: Error)
}


struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { receivedData in
            let fileName = receivedData.file.lastPathComponent
            let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: receivedData.file, to: copy)
            return .init(url: copy)
        }
    }
}
