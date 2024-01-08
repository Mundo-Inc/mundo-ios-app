//
//  EditListVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/8/24.
//

import Foundation
import SwiftUI

@MainActor
final class EditListVM: ObservableObject {
    let originalList: UserPlacesList
    let onSuccess: (UserPlacesList) -> Void
    let onCancel: () -> Void
    
    private let dataManager = ListsDM()
    
    @Published var step: Step = .general
    
    @Published var isEmojiAnimating = true
    
    @Published var isLoading = false
    @Published var showAddListCollaborators = false
    
    @Published var name: String
    @Published var icon: EmojisManager.Emoji
    @Published var collaborators: [ListCollaborator]
    @Published var isPrivate: Bool
    
    var isReadyToSubmit: Bool {
        !self.name.isEmpty && self.name.count <= 16 && !self.isLoading
    }
    
    init(originalList: UserPlacesList, onSuccess: @escaping (UserPlacesList) -> Void, onCancel: @escaping () -> Void) {
        self.originalList = originalList
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        
        self.name = originalList.name
        self.icon = .init(symbol: originalList.icon)
        self.collaborators = originalList.collaborators.filter({ $0.user.id != originalList.owner.id })
        self.isPrivate = originalList.isPrivate
    }
    
    func submit() async {
        // collaborator changes
        let newCollaborators = self.collaborators.filter({ c in
            return !self.originalList.collaborators.contains(where: { oc in
                return oc.user.id == c.user.id
            })
        })
        let removedCollaborators = self.originalList.collaborators.filter({ oc in
            if oc.user.id == originalList.owner.id {
                return false
            }
            return !self.collaborators.contains(where: { c in
                return oc.user.id == c.user.id
            })
        })
        let editedCollaborators = self.collaborators.filter({ c in
            return self.originalList.collaborators.contains(where: { oc in
                return oc.user.id == c.user.id && oc.access != c.access
            })
        })

        // name changes
        let nameChanged = self.name != self.originalList.name

        // icon changes
        let iconChanged = self.icon.symbol != self.originalList.icon

        // privacy changes
        let privacyChanged = self.isPrivate != self.originalList.isPrivate

        guard !newCollaborators.isEmpty || !removedCollaborators.isEmpty || !editedCollaborators.isEmpty || nameChanged || iconChanged || privacyChanged else {
            self.onCancel()
            return
        }

        self.isLoading = true
        
        if !newCollaborators.isEmpty {
            for c in newCollaborators {
                do {
                    try await dataManager.addCollaborator(listId: self.originalList.id, userId: c.user.id, access: c.access)
                } catch {
                    print(error)
                }
            }
        }
        if !removedCollaborators.isEmpty {
            for c in removedCollaborators {
                do {
                    try await dataManager.removeCollaborator(listId: self.originalList.id, userId: c.user.id)
                } catch {
                    print(error)
                }
            }
        }
        if !editedCollaborators.isEmpty {
            for c in editedCollaborators {
                do {
                    try await dataManager.editCollaborator(listId: self.originalList.id, userId: c.user.id, changeAccessTo: c.access)
                } catch {
                    print(error)
                }
            }
        }
        
        // TODO: Name, Icon, Privacy
        
        do {
            let list = try await dataManager.getList(withId: self.originalList.id)
            self.onSuccess(list)
        } catch {
            print(error)
            self.onCancel()
        }
        
        self.isLoading = false
    }
    
    enum Step {
        case general
        case collaborators
    }
}
