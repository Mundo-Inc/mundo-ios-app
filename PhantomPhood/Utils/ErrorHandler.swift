//
//  ErrorHandler.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/17/24.
//

import Foundation

func presentErrorToast(_ error: Error, title: String? = nil, debug: String? = nil, silent: Bool = false, function: String? = nil) {
    if !silent {
        if let apiError = error as? APIManager.APIError {
            switch apiError {
            case .serverError(let serverError):
                ToastVM.shared.toast(.init(type: .error, title: title ?? serverError.statusCode.description, message: serverError.message))
            case .decodingError(let error):
                ToastVM.shared.toast(.init(type: .error, title: title ?? "Decoding Error", message: error.localizedDescription))
            case .unknown:
                ToastVM.shared.toast(.init(type: .error, title: title ?? "Unknown Error", message: error.localizedDescription))
            }
        } else if error.localizedDescription != "cancelled" {
            ToastVM.shared.toast(.init(type: .error, title: title ?? "Unknown Error", message: error.localizedDescription))
        }
    }
 
#if DEBUG
    if let debug {
        print(debug, error, function ?? "-")
    } else if error.localizedDescription != "cancelled" {
        print(error)
    }
#endif
}

func getErrorMessage(_ error: Error) -> String {
    if let apiError = error as? APIManager.APIError {
        switch apiError {
        case .serverError(let serverError):
            return serverError.message
        case .decodingError(let error):
            return error.localizedDescription
        case .unknown:
            return error.localizedDescription
        }
    } else {
        return error.localizedDescription
    }
}
