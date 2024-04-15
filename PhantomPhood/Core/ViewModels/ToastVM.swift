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
    case error
    case info
    
    var color: Color {
        switch self {
        case .success:
            Color.green.opacity(0.2)
        case .error:
            Color.red.opacity(0.2)
        case .info:
            Color.clear
        }
    }
    
    var title: String {
        switch self {
        case .success:
            return "Success"
        case .error:
            return "Error"
        case .info:
            return "Info"
        }
    }
}

struct Toast: Identifiable {
    let id = UUID().uuidString
    let type: ToastType
    let title: String
    let message: String
    let redirect: AppRoute?
    
    init(type: ToastType, title: String, message: String, redirect: AppRoute? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.redirect = redirect
    }
}

final class ToastVM: ObservableObject {
    static let shared = ToastVM()
    private init() {}
    
    private let userProfileDM = UserProfileDM()
    
    @Published private(set) var toasts: [Toast] = []
    
    public func toast(_ item: Toast) {
        DispatchQueue.main.async {
            self.toasts.append(item)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.remove(id: item.id)
        }
    }
    
    
    public func toast(type: ToastType, from userId: String, message: String, redirect: AppRoute?, fallbackTitle: String? = nil) async {
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
    
    @MainActor
    func remove(id: String) {
        toasts = toasts.filter({ item in
            item.id != id
        })
    }
}
