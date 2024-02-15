//
//  APIManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 13.09.2023.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    static let baseURL = "https://phantomphood.ai/api/v1"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: configuration)
    }
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
}

extension APIManager {
    // MARK: - Public Methods
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType = .applicationJson
    ) async throws -> (data: T?, response: HTTPURLResponse) {
        let request = try buildRequest(endpoint: endpoint, method: method, body: body, queryParams: queryParams, token: token, contentType: contentType)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try decode(ServerResponseError.self, from: data)
            throw APIError.serverError(.init(success: serverError.success, error: serverError.error, statusCode: httpResponse.statusCode))
        }
        
        // Handle 204 No Content
        if httpResponse.statusCode == 204 {
            return (nil, httpResponse)
        }
        
        return ((try decode(T.self, from: data)), httpResponse)
    }
    
    func requestData<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType = .applicationJson
    ) async throws -> T? {
        let request = try buildRequest(endpoint: endpoint, method: method, body: body, queryParams: queryParams, token: token, contentType: contentType)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverError = try decode(ServerResponseError.self, from: data)
            throw APIError.serverError(.init(success: serverError.success, error: serverError.error, statusCode: httpResponse.statusCode))
        }
        
        // Handle 204 No Content
        if httpResponse.statusCode == 204 {
            return nil
        }
        
        return try decode(T.self, from: data)
    }
    
    @discardableResult
    func requestNoContent(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
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
            throw APIError.serverError(.init(success: serverError.success, error: serverError.error, statusCode: httpResponse.statusCode))
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
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType
    ) throws -> URLRequest {
        guard var components = URLComponents(string: "\(APIManager.baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        // Handle query parameters
        if let queryParams = queryParams {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)) }
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
            throw APIError.decodingError(error)
        }
    }
}

extension APIManager {
    // MARK: - Structs and Enums
    
    struct ServerResponseError: Decodable {
        let success: Bool
        let error: ErrorData
        
        struct ErrorData: Codable {
            let message: String
        }
    }
    
    struct ServerError: Codable {
        let success: Bool
        let error: ServerResponseError.ErrorData
        let statusCode: Int
        // Convenience property to get the main error message
        var message: String {
            return error.message
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
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
