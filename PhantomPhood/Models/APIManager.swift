//
//  APIManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 13.09.2023.
//

import Foundation

class APIManager {
    
    // MARK: - Nested Types
    
    struct ServerError: Codable {
        let success: Bool
        let error: ErrorRes
        
        struct ErrorRes: Codable {
            let message: String
        }
        
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
    }
    
    // MARK: - Constants
    
//    static let baseURL = "http://localhost:3020/api/v1"
    static let baseURL = "https://phantomphood.ai/api/v1"
    
    // MARK: - Public Methods
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType? = .applicationJson
    ) async throws -> (data: T?, response: HTTPURLResponse) {
        
        var components = URLComponents(string: "\(APIManager.baseURL)\(endpoint)")
        
        // Handle query parameters
        if let queryParams = queryParams {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        switch contentType {
        case .applicationJson:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .multipartFormData(let boundary):
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        case nil:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let authToken = token {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        if let bodyData = body {
            request.httpBody = bodyData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            // Try decoding server error
            if let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw APIError.serverError(serverError)
            } else {
                throw APIError.unknown
            }
        }
        
        // Handle 204 No Content
        if httpResponse.statusCode == 204 {
            return (nil, httpResponse)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return (decodedData, httpResponse)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func requestData<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType? = .applicationJson
    ) async throws -> T? {
        
        var components = URLComponents(string: "\(APIManager.baseURL)\(endpoint)")
        
        // Handle query parameters
        if let queryParams = queryParams {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        switch contentType {
        case .applicationJson:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .multipartFormData(let boundary):
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        case nil:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let authToken = token {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        if let bodyData = body {
            request.httpBody = bodyData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            // Try decoding server error
            if let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw APIError.serverError(serverError)
            } else {
                throw APIError.unknown
            }
        }
        
        // Handle 204 No Content
        if httpResponse.statusCode == 204 {
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.decodingError(error)
        }
    }
        
    func requestNoContent(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        token: String? = nil,
        contentType: ContentType? = .applicationJson
    ) async throws -> HTTPURLResponse {
        
        var components = URLComponents(string: "\(APIManager.baseURL)\(endpoint)")
        
        // Handle query parameters
        if let queryParams = queryParams {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        switch contentType {
        case .applicationJson:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .multipartFormData(let boundary):
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        case nil:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let authToken = token {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }
        
        if let bodyData = body {
            request.httpBody = bodyData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            // Try decoding server error
            if let serverError = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw APIError.serverError(serverError)
            } else {
                throw APIError.unknown
            }
        }
        
        return httpResponse
    }
    
    func createRequestBody<T: Encodable>(_ data: T) throws -> Data {
        return try JSONEncoder().encode(data)
    }

}
