//
//  UserDataStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/27/24.
//

import Foundation
import CoreData

final class UserDataStack {
    static let shared = UserDataStack()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserDataContainer")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveUsers(userEssentialsList: [UserProfileDM.UserEssentialsWithCreationDate]) {
        self.viewContext.perform {
            let ids: Set<String> = Set(userEssentialsList.compactMap { $0.id })
            let existingUsers = self.fetchUsers(withIDs: ids)

            let existingUsersDict = Dictionary(uniqueKeysWithValues: existingUsers.compactMap { ($0.id, $0) })

            for essentials in userEssentialsList {
                let user = existingUsersDict[essentials.id] ?? ReferredUserEntity(context: self.viewContext)
                self.updateReferredUserEntity(user, with: essentials)
            }
            
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                } catch {
                    presentErrorToast(error, debug: "Error saving users info to CoreData", silent: false)
                }
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() async throws {
        try await viewContext.perform {
            if self.viewContext.hasChanges {
                try self.viewContext.save()
            }
        }
    }
    
    // MARK: Private methods
    
    private func fetchUsers(withIDs ids: Set<String>) -> [ReferredUserEntity] {
        let request: NSFetchRequest<ReferredUserEntity> = ReferredUserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            return try self.viewContext.fetch(request)
        } catch {
            presentErrorToast(error, debug: "Failed to fetch users from CoreData", silent: true)
            return []
        }
    }
    
    private func updateReferredUserEntity(_ user: ReferredUserEntity, with essentialsWithDate: UserProfileDM.UserEssentialsWithCreationDate) {
        user.id = essentialsWithDate.id
        user.name = essentialsWithDate.name
        user.username = essentialsWithDate.username
        user.verified = essentialsWithDate.verified
        user.profileImage = essentialsWithDate.profileImage?.absoluteString
        user.level = Int16(essentialsWithDate.progress.level)
        user.xp = Int16(essentialsWithDate.progress.xp)
        user.createdAt = essentialsWithDate.createdAt
        user.savedAt = Date()
    }
}
