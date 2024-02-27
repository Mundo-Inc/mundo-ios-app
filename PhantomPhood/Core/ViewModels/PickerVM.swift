//
//  PickerVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
class PickerVM: ObservableObject {
    @Published var selection: [PhotosPickerItem] = [] {
        didSet {
            onSelectionChange()
        }
    }
    @Published private(set) var mediaItems: [MediaItem] = []
    
    private let limitToOne: Bool
    
    init(limitToOne: Bool = false) {
        self.limitToOne = limitToOne
    }
    
    var isReadyToSubmit: Bool {
        mediaItems.allSatisfy({ mediaItem in
            if case .loaded(_) = mediaItem.state {
                return true
            } else {
                return false
            }
        })
    }
    
    func cameraHandler(_ data: Data) {
        if let uiImage = UIImage(data: data) {
            DispatchQueue.main.async {
                if self.limitToOne {
                    if !self.selection.isEmpty {
                        self.selection.removeAll()
                    }
                    self.mediaItems = [MediaItem(id: UUID().uuidString, source: .camera, state: .loaded(.image(uiImage)))]
                } else {
                    self.mediaItems.append(MediaItem(id: UUID().uuidString, source: .camera, state: .loaded(.image(uiImage))))
                }
                
            }
        }
    }
    
    func removeItem(_ item: MediaItem) {
        if limitToOne {
            selection.removeAll()
        } else {
            if item.source == .camera {
                if let firstIndex = self.mediaItems.firstIndex(where: { $0.id == item.id }) {
                    self.mediaItems.remove(at: firstIndex)
                }
            } else {
                if let firstIndex = selection.firstIndex(where: { photoPickerItem in
                    if let itemIdentifier = photoPickerItem.itemIdentifier {
                        return itemIdentifier == item.id
                    }
                    return false
                }) {
                    self.selection.remove(at: firstIndex)
                }
            }
        }
    }
    
    private func onSelectionChange() {
        if limitToOne {
            self.mediaItems.removeAll()
        } else {
            self.mediaItems.removeAll { $0.source == .gallery }
        }
        
        for item in selection {
            let id = item.itemIdentifier ?? UUID().uuidString
            let progress = loadTransferable(from: item, id: id)
            self.mediaItems.append(.init(id: id, source: .gallery, state: .loading(progress)))
        }
    }
    
    private func loadTransferable(from pickerItem: PhotosPickerItem, id: String) -> Progress {
        if pickerItem.isVideo {
            return pickerItem.loadTransferable(type: Movie.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .loaded(.movie(data.url)))
                            }
                            return item
                        })
                    case .success(nil):
                        break
                        //                    self.mediaItemsState.removeAll { item in
                        //                        item.id == id
                        //                    }
                    case .failure(let error):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error))
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
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                if let uiImage = UIImage(data: data) {
                                    return item.newState(state: .loaded(.image(uiImage)))
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
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error))
                            }
                            return item
                        })
                    }
                }
            }
        }
    }
}

struct MediaItem: Identifiable {
    let id: String
    let source: MediaItemSource
    var state: MediaItemState
    
    func newState(state newState: MediaItemState) -> MediaItem {
        return MediaItem(id: self.id, source: self.source, state: newState)
    }
    
    enum MediaItemSource {
        case gallery
        case camera
    }
}

enum MediaItemState {
    case empty
    case loading(Progress)
    case failure(Error)
    case loaded(MediaItemData.MediaData)
}

struct MediaItemData {
    let id: String
    var state: MediaData
    
    enum MediaData {
        case image(UIImage)
        case movie(URL)
    }
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
