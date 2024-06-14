//
//  ErrorHandler.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/17/24.
//

import Foundation

func presentErrorToast(
    _ error: Error,
    title: String? = nil,
    debug: String? = nil,
    silent: Bool = false,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
#if DEBUG
    if let debug {
        print("\n# ERROR #\n")
        print(debug)
        print(error)
        print(function)
        print(file, line)
    } else if error.localizedDescription != "cancelled" {
        print("\n# ERROR #\n")
        print(error)
        print(function)
        print(file, line)
    }
#endif
    guard !silent else { return }
    
    let fileName = file.split(separator: "/").last ?? "-"
    
    if let apiError = error as? APIManager.APIError {
        switch apiError {
        case .serverError(let serverError):
            ToastVM.shared.toast(Toast(
                type: .userError,
                title: title ?? serverError.title,
                message: serverError.message
            ))
        case .decodingError(let error):
            ToastVM.shared.toast(Toast(
                type: .systemError(errorMessage: error.localizedDescription, function: function, file: file, line: line),
                title: title ?? "Decoding Error",
                message: error.localizedDescription + "\n" + function + "\n" + "\(fileName) | \(line)"
            ))
        case .unknown:
            ToastVM.shared.toast(Toast(
                type: .systemError(errorMessage: error.localizedDescription, function: function, file: file, line: line),
                title: title ?? "Unknown API Error",
                message: error.localizedDescription + "\n" + function + "\n" + "\(fileName) | \(line)"
            ))
        }
    } else if error.localizedDescription != "cancelled" {
        ToastVM.shared.toast(Toast(
            type: .systemError(errorMessage: error.localizedDescription, function: function, file: file, line: line),
            title: title ?? "Unknown Error",
            message: error.localizedDescription + "\n" + function + "\n" + "\(fileName) | \(line)"
        ))
    }
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
