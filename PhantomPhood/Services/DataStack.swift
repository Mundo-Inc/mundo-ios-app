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
    
    func createOrUpdateUser(userEssentials: UserEssentials) {
        do {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userEssentials.id)
            request.fetchLimit = 1
            
            if let user = try self.viewContext.fetch(request).first {
                user.name = userEssentials.name
                user.username = userEssentials.username
                user.verified = userEssentials.verified
                user.profileImage = userEssentials.profileImage?.absoluteString
                user.level = Int16(userEssentials.progress.level)
                user.xp = Int16(userEssentials.progress.xp)
                user.savedAt = Date()
                
                if user.hasChanges {
                    try self.viewContext.save()
                }
            } else {
                let user = UserEntity(context: self.viewContext)
                user.id = userEssentials.id
                user.name = userEssentials.name
                user.username = userEssentials.username
                user.verified = userEssentials.verified
                user.profileImage = userEssentials.profileImage?.absoluteString
                user.level = Int16(userEssentials.progress.level)
                user.xp = Int16(userEssentials.progress.xp)
                user.savedAt = Date()
                
                try self.viewContext.save()
            }
        } catch {
            presentErrorToast(error, debug: "Error saving user infor to CoreData", silent: true)
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
}
