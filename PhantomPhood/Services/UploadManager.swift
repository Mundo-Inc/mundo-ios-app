//
//  UploadManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation

final class UploadManager {
    static let shared = UploadManager()
    
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    private init() {}
    
    enum UploadManagerError: Error {
        case cantCreateDataFromVideoURL
    }
    
    func uploadMedia(media: CompressedMediaData, usecase: UploadUseCase) async throws -> ResponseData {
        let token = try await auth.getToken()
        
        switch media {
        case .image(let data):
            let (formData, boundary) = UploadManager.uploadFormDataBody(file: UploadFile(name: UUID().uuidString + ".jpg", data: data, type: .image), usecase: usecase)
            let resData: APIResponse<ResponseData> = try await apiManager.requestData("/upload", method: .post, body: formData, token: token, contentType: .multipartFormData(boundary: boundary))
            return resData.data
        case .movie(let url):
            guard let data = try? Data(contentsOf: url) else {
                throw UploadManagerError.cantCreateDataFromVideoURL
            }
            
            let (formData, boundary) = UploadManager.uploadFormDataBody(file: UploadFile(name: UUID().uuidString + ".mp4", data: data, type: .video), usecase: usecase)
            let resData: APIResponse<ResponseData> = try await apiManager.requestData("/upload", method: .post, body: formData, token: token, contentType: .multipartFormData(boundary: boundary))
            return resData.data
        }
    }
    
    /// Returns MediaIds that can be used to send requests with media to server
    static func getMediaIds(from mediaItems: [AsyncTaskMedia]?) -> [MediaIds]? {
        guard let mediaItems else {
            return nil
        }
        
        let items = mediaItems.compactMap { $0.mediaId }
        
        return items.isEmpty ? nil : items
    }
    
    static private func uploadFormDataBody(file: UploadFile, usecase: UploadUseCase) -> (formData: Data, boundary: String) {
        let boundary = "Boundary-\(UUID().uuidString)"
        /// line break
        let lb = "\r\n"
        var body = Data()
        
        body.append("\(lb)--\(boundary + lb)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"usecase\"\(lb + lb + usecase.rawValue)".data(using: .utf8)!)
        
        body.append("\(lb)--\(boundary + lb)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(file.type.rawValue.components(separatedBy: "/").first!)\"; filename=\"\(file.name)\"\(lb)".data(using: .utf8)!)
        body.append("Content-Type: \(file.type.rawValue)\(lb + lb)".data(using: .utf8)!)
        body.append(file.data)
        
        body.append("\(lb)--\(boundary)--\(lb)".data(using: .utf8)!)
        
        return (body, boundary)
    }
    
    /// Use when sending mediaIds to server
    struct MediaIds: Encodable {
        let uploadId: String
        let caption: String
    }
    
    /// API response type on uploading media
    struct ResponseData: Decodable, Identifiable {
        let id: String
        let user: String
        let key: String
        let src: URL?
        let type: String
        let usecase: String
        let createdAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case user, key, src, type, usecase, createdAt
        }
    }
    
    /// Usecase of the uploading media (This is required to send request to server)
    enum UploadUseCase: String {
        case checkIn = "checkin"
        case profileImage = "profileImage"
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
}
