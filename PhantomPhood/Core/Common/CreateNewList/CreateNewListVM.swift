//
//  CreateNewListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation
import SwiftUI

@MainActor
final class CreateNewListVM: ObservableObject {
    let onSuccess: (UserPlacesList) -> Void
    let onCancel: () -> Void
    
    private let listsDM = ListsDM()
    
    @Published var presentingSheet: Sheet? = nil
    
    @Published var step: Step = .general
    
    @Published var isEmojiAnimating = true
    
    @Published var isLoading = false
    
    @Published var name: String = ""
    @Published var icon: EmojisManager.Emoji = .init(symbol: "❤️", title: "Heart", keywords: [], categories: [], isAnimated: true, unicode: "2764_fe0f")
    @Published var collaborators: [ListCollaborator] = []
    @Published var isPrivate: Bool = false
    
    var isReadyToSubmit: Bool {
        !self.name.isEmpty && self.name.count <= 16 && !self.isLoading
    }
    
    init(onSuccess: @escaping (UserPlacesList) -> Void, onCancel: @escaping () -> Void) {
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }
    
    func submit() async {
        self.isLoading = true
        do {
            let list = try await listsDM.createList(body: .init(name: name, icon: icon.symbol, collaborators: collaborators.map({ c in
                return .init(user: c.user.id, access: c.access.rawValue)
            }), isPrivate: isPrivate))
            
            self.onSuccess(list)
        } catch {
            presentErrorToast(error)
            self.onCancel()
        }
        self.isLoading = false
    }
    
    // MARK: Enums
    
    enum Step {
        case general
        case collaborators
    }
    
    enum Sheet: Identifiable {
        case reactionSelector(onSelect: (EmojisManager.Emoji) -> Void)
        case userSelector(onSelect: (UserEssentials) -> Void)
        
        var id: String {
            switch self {
            case .reactionSelector(let onSelect):
                return String(describing: onSelect)
            case .userSelector(let onSelect):
                return String(describing: onSelect)
            }
        }
    }
}
