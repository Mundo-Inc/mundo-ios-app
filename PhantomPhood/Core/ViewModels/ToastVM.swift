//
//  ToastVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/11/23.
//

import Foundation
import SwiftUI

enum ToastType {
    case success
    case userError
    case systemError(errorMessage: String, function: String, file: String, line: Int)
    case info
    
    var color: Color {
        switch self {
        case .success:
            Color.green
        case .userError:
            Color.orange
        case .systemError:
            Color.red
        case .info:
            Color.cyan
        }
    }
    
    var title: String {
        switch self {
        case .success:
            return "Success"
        case .userError:
            return "Failed"
        case .systemError:
            return "Error"
        case .info:
            return "Info"
        }
    }
    
    var icon: String {
        return switch self {
        case .success:
            "checkmark.circle"
        case .userError:
            "exclamationmark.triangle"
        case .systemError:
            "exclamationmark.octagon"
        case .info:
            "info.circle"
        }
    }
}

struct Toast: Identifiable {
    let id = UUID()
    let type: ToastType
    let title: String
    let message: String
    let redirect: AppRoute?
    
    let createdAt: Date = .now
    var expiresAt: Date?
    
    init(type: ToastType, title: String, message: String, redirect: AppRoute? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.redirect = redirect
        self.expiresAt = .now + 5
    }
}

final class ToastVM: ObservableObject {
    static let shared = ToastVM()
    private init() {}
    
    private let userProfileDM = UserProfileDM()
    private let reportDM = ReportDM()
    
    @Published private(set) var toasts: [Toast] = []
    
    @Published var dragToast: (amount: CGFloat, id: UUID?) = (.zero, nil)
    
    public func toast(_ item: Toast) {
        DispatchQueue.main.async {
            self.toasts.append(item)
        }
        if let expiresAt = item.expiresAt {
            DispatchQueue.main.asyncAfter(deadline: .now() + expiresAt.timeIntervalSince(Date.now) + 0.1) {
                if let ti = self.toasts.first(where: { $0.id == item.id }), let exp = ti.expiresAt, Date.now > exp {
                    self.remove(id: ti.id)
                }
                
            }
        }
    }
    
    public func report(toast: Toast) async {
        if case .systemError(let errorMessage, let function, let file, let line) = toast.type {
            do {
                try await reportDM.reportBug(report: .init(function: function, file: file, line: line, message: errorMessage))
                remove(id: toast.id)
                self.toast(Toast(type: .success, title: "Thanks", message: "Thanks for reporting the bug!"))
            } catch {
                print(error)
            }
        }
    }
    
    public func persist(with toastId: UUID) {
        DispatchQueue.main.async {
            if let index = self.toasts.firstIndex(where: { $0.id == toastId }) {
                self.toasts[index].expiresAt = nil
            }
        }
    }
    
    public func toast(
        type: ToastType,
        from userId: String,
        message: String,
        redirect: AppRoute?,
        fallbackTitle: String? = nil
    ) async {
        do {
            if let user = try await userProfileDM.getUserEssentialsAndUpdate(id: userId, returnIfFound: true, coreDataCompletion: { user in
                self.toast(.init(type: type, title: user.name, message: message, redirect: redirect))
            }) {
                self.toast(.init(type: type, title: user.name, message: message, redirect: redirect))
            }
        } catch {
            self.toast(.init(type: type, title: fallbackTitle ?? type.title, message: message, redirect: redirect))
        }
    }
    
    func remove(id: UUID) {
        DispatchQueue.main.async {
            self.toasts.removeAll { $0.id == id }
        }
    }
}
