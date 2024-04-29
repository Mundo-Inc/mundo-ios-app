//
//  DataStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/27/24.
//

import Foundation
import CoreData

final class DataStack {
    static let shared = DataStack()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataContainer")
        
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
    
    func removeRequestedRegions() async throws {
        let fetchedRegionsRequest: NSFetchRequest<RequestedRegionEntity> = RequestedRegionEntity.fetchRequest()
        
        let fetchedRegions = try persistentContainer.viewContext.fetch(fetchedRegionsRequest)
        
        fetchedRegions.forEach { persistentContainer.viewContext.delete($0) }
        
        try await saveContext()
    }
    
    func removeMapActivities() async throws {
        let mapActivitiesRequest: NSFetchRequest<MapActivityEntity> = MapActivityEntity.fetchRequest()
        
        let mapActivities = try persistentContainer.viewContext.fetch(mapActivitiesRequest)
        
        mapActivities.forEach { persistentContainer.viewContext.delete($0) }
        
        try await saveContext()
    }
    
    func removeUsers() async throws {
        let usersRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        let users = try persistentContainer.viewContext.fetch(usersRequest)
        
        users.forEach { persistentContainer.viewContext.delete($0) }
        
        try await saveContext()
    }
    
    func removePlaces() async throws {
        let placesRequest: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        
        let places = try persistentContainer.viewContext.fetch(placesRequest)
        
        places.forEach { persistentContainer.viewContext.delete($0) }
        
        try await saveContext()
    }
    
    
    func deleteAll(completion: @escaping (Bool) -> Void) {
        let context = viewContext
        
        context.perform {
            let entityNames = ["RequestedRegionEntity", "MapActivityEntity", "UserEntity", "PlaceEntity"]
            
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                batchDeleteRequest.resultType = .resultTypeCount
                
                do {
                    let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                    print("Deleted \(batchDeleteResult?.result ?? 0) records from \(entityName)")
                } catch {
                    presentErrorToast(error, debug: "Error deleting entity \(entityName): \(error)", silent: true)
                    context.rollback()  // Important to maintain integrity in case of failure
                    completion(false)
                    return
                }
            }
            
            // Save context to persist changes
            do {
                try context.save()
                completion(true)
            } catch {
                presentErrorToast(error, debug: "Failed to save context", silent: true)
                context.rollback()
                completion(false)
            }
        }
    }
    
    func saveUser(userEssentials: UserEssentials) {
        viewContext.perform {
            do {
                let user = try self.fetchUser(withID: userEssentials.id) ?? UserEntity(context: self.viewContext)
                
                self.updateUserEntity(user, with: userEssentials)
                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                }
            } catch {
                presentErrorToast(error, debug: "Error saving user info to CoreData", silent: true)
            }
        }
    }
    
    func saveUsers(userEssentialsList: [UserEssentials]) {
        let ids: Set<String> = Set(userEssentialsList.compactMap { $0.id })

        viewContext.perform {
            let existingUsers = self.fetchUsers(withIDs: ids)

            let existingUsersDict = Dictionary(uniqueKeysWithValues: existingUsers.compactMap { ($0.id, $0) })

            for essentials in userEssentialsList {
                let user = existingUsersDict[essentials.id] ?? UserEntity(context: self.viewContext)
                self.updateUserEntity(user, with: essentials)
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
    
    private func fetchUser(withID id: String) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try self.viewContext.fetch(request).first
    }
    
    private func fetchUsers(withIDs ids: Set<String>) -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            return try self.viewContext.fetch(request)
        } catch {
            presentErrorToast(error, debug: "Failed to fetch users from CoreData", silent: true)
            return []
        }
    }
    
    private func updateUserEntity(_ user: UserEntity, with essentials: UserEssentials) {
        user.id = essentials.id
        user.name = essentials.name
        user.username = essentials.username
        user.verified = essentials.verified
        user.profileImage = essentials.profileImage?.absoluteString
        user.level = Int16(essentials.progress.level)
        user.xp = Int16(essentials.progress.xp)
        user.savedAt = Date()
    }
}
