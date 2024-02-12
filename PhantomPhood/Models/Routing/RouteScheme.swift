//
//  RouteScheme.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/8/24.
//

import Foundation

/// Route Scheme
/// - Note: Optional parameters in pattern are marked with `?` and they should be the last items in the pattern
struct RouteScheme {
    let pattern: [String]
    let router: Router
    private let authRouteGetter: (([String]) throws -> AuthRoute)?
    private let routeGetter: (([String]) throws -> AppRoute)?
    private let validator: ([String]) throws -> Void
    
    init(pattern: [String], routeGetter: @escaping ([String]) throws -> AppRoute, validator: @escaping ([String]) throws -> Void = { _ in }) {
        self.pattern = pattern
        self.router = .app
        self.validator = validator
        self.routeGetter = routeGetter
        self.authRouteGetter = nil
    }
    
    init(pattern: [String], authRouteGetter: @escaping ([String]) throws -> AuthRoute, validator: @escaping ([String]) throws -> Void = { _ in }) {
        self.pattern = pattern
        self.router = .auth
        self.validator = validator
        self.authRouteGetter = authRouteGetter
        self.routeGetter = nil
    }
    
    var requiredParams: [String] {
        self.pattern.filter({ !$0.contains("?") })
    }
    
    var optionalParams: [String] {
        self.pattern.filter({ $0.contains("?") })
    }
    
    func validate(_ components: [String]) throws {
        guard components.count >= requiredParams.count else {
            throw LinkingError.missingParam
        }
        try validator(components)
    }
    
    func getRoute(_ components: [String]) throws -> AppRoute {
        guard let routeGetter else {
            throw LinkingError.wrongMethod
        }
        return try routeGetter(components)
    }
    
    func getAuthRoute(_ components: [String]) throws -> AuthRoute {
        guard let authRouteGetter else {
            throw LinkingError.wrongMethod
        }
        return try authRouteGetter(components)
    }
    
    enum Router {
        case auth
        case app
    }
}

enum LinkingError: LocalizedError {
    case missingParam
    case badParam
    case wrongMethod
}
