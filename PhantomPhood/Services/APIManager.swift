//
//  APIManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 13.09.2023.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    static let baseURL = K.ENV.APIBaseURL
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: configuration)
    }
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func getData<T: Decodable>(_ data: [Any]) throws -> T {
        guard let dataDictionary = data.first as? [String: Any] else {
            throw DataDecodingError.invalidDataFormat
        }
        
        do {
            let myData = try JSONSerialization.data(withJSONObject: dataDictionary)
            let response = try Self.decoder.decode(T.self, from: myData)
            return response
        } catch let error as DecodingError {
            throw DataDecodingError.decodingFailed(error)
        } catch let error {
            throw DataDecodingError.jsonSerializationFailed(error)
        }
    }
}

extension APIManager {
    
    // MARK: - Public Methods
    
    func requestData<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String?]? = nil,
        token: String? = nil,
        contentType: ContentType = .applicationJson
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: method, body: body, queryParams: queryParams, token: token, contentType: contentType)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try decode(ServerResponseError.self, from: data)
            throw APIError.serverError(.init(status: serverError.status, error: serverError.error, statusCode: httpResponse.statusCode))
        }
        
        return try decode(T.self, from: data)
    }
    
    @discardableResult
    func requestNoContent(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String?]? = nil,
        token: String? = nil,
        contentType: ContentType = .applicationJson
    ) async throws -> HTTPURLResponse {
        let request = try buildRequest(endpoint: endpoint, method: method, body: body, queryParams: queryParams, token: token, contentType: contentType)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try decode(ServerResponseError.self, from: data)
            throw APIError.serverError(.init(status: serverError.status, error: serverError.error, statusCode: httpResponse.statusCode))
        }
        
        return httpResponse
    }
    
    /// Create a request body (Data) from an Encodable object
    /// - Parameter data: Encodable object
    /// - Returns: Data
    func createRequestBody<T: Encodable>(_ data: T) throws -> Data {
        return try JSONEncoder().encode(data)
    }
}

extension APIManager {
    
    // MARK: - Private Methods
    
    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        queryParams: [String: String?]? = nil,
        token: String? = nil,
        contentType: ContentType
    ) throws -> URLRequest {
        guard var components = URLComponents(string: "\(APIManager.baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        // Handle query parameters
        if let queryParams = queryParams {
            components.queryItems = queryParams.compactMap {
                return if let value = $0.value {
                    URLQueryItem(name: $0.key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                } else {
                    nil
                }
            }
        }
        
        guard let finalURL = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.addValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
        
        // Set Authorization token if available
        if let authToken = token {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        // Set request body if available
        request.httpBody = body
        
        return request
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try APIManager.decoder.decode(T.self, from: data)
        } catch {
#if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response Data: \(jsonString)")
            } else {
                print("Failed to convert data to a String.")
            }
#endif
            throw APIError.decodingError(error)
        }
    }
}

extension APIManager {
    // MARK: - Structs and Enums
    
    struct ServerResponseError: Decodable {
        let status: String
        let error: ErrorData
        
        struct ErrorData: Codable {
            let type: String
            let message: String
            let details: Details?
            
            struct Details: Codable {
                let message: String
            }
        }
    }
    
    struct ServerError: Codable {
        let status: String
        let error: ServerResponseError.ErrorData
        let statusCode: Int
        
        var title: String {
            "\(error.type) (\(statusCode))"
        }
        
        // Convenience property to get the main error message
        var message: String {
            error.message
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum APIError: Error {
        case serverError(ServerError)
        case decodingError(Error)
        case unknown
    }
    
    enum ContentType {
        case applicationJson
        case multipartFormData(boundary: String)
        
        var headerValue: String {
            switch self {
            case .applicationJson:
                return "application/json"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            }
        }
    }
}

enum DataDecodingError: Error {
    case invalidDataFormat
    case jsonSerializationFailed(Error)
    case decodingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidDataFormat:
            return "The data is not in the expected format."
        case .jsonSerializationFailed:
            return "Failed to serialize JSON data."
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}
