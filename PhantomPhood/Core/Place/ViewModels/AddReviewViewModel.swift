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
    
    @Published var step: Steps = .recommendation
    
    @Published var isRecommended: Bool? = nil
    @Published var overallScore: Int? = nil
    @Published var foodQuality: Int? = nil
    @Published var drinkQuality: Int? = nil
    @Published var service: Int? = nil
    @Published var atmosphere: Int? = nil
    
    @Published var isPublic = true
    @Published var reviewContent = ""

    var haveAnyScore: Bool {
        overallScore != nil || foodQuality != nil || drinkQuality != nil || service != nil || atmosphere != nil
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
                        print("Success Video")
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
                        print("Success Image")
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
            let asset = AVAsset(url: movie.url)
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let compressedVideoURL = documentsPath.appendingPathComponent("compressedVideo.mp4")
            
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
                print("Completed Compression")
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
