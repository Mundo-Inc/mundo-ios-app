//
//  ToastVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/11/23.
//

import Foundation

enum ToastType {
    case success
    case error
}

struct Toast: Identifiable {
    let id = UUID().uuidString
    let type: ToastType
    let title: String
    let message: String
}

@MainActor
final class ToastVM: ObservableObject {
    static let shared = ToastVM()
    private init() {}
    
    @Published private(set) var toasts: [Toast] = []
    
    func toast(_ item: Toast) {
        toasts.append(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.remove(id: item.id)
        }
    }
    
    func remove(id: String) {
        toasts = toasts.filter({ item in
            item.id != id
        })
    }
}
