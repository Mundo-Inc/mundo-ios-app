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
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Error loading store: \(error), \(error.userInfo)")
            }
            
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func removeRequestedRegions() throws {
        let fetchedRegionsRequest: NSFetchRequest<RequestedRegionEntity> = RequestedRegionEntity.fetchRequest()
        
        try viewContext.performAndWait {
            let fetchedRegions = try viewContext.fetch(fetchedRegionsRequest)
            
            fetchedRegions.forEach { viewContext.delete($0) }
            
            if viewContext.hasChanges {
                try viewContext.save()
            }
        }
    }
    
    func removeMapActivities() throws {
        let mapActivitiesRequest: NSFetchRequest<MapActivityEntity> = MapActivityEntity.fetchRequest()
        
        try viewContext.performAndWait {
            let mapActivities = try viewContext.fetch(mapActivitiesRequest)
            
            mapActivities.forEach { viewContext.delete($0) }
            
            if viewContext.hasChanges {
                try viewContext.save()
            }
        }
    }
    
    func removeUsers() throws {
        let usersRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        try viewContext.performAndWait {
            let users = try viewContext.fetch(usersRequest)
            
            users.forEach { viewContext.delete($0) }
            
            if viewContext.hasChanges {
                try viewContext.save()
            }
        }
    
        
    }
    
    func removePlaces() throws {
        let placesRequest: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        
        try viewContext.performAndWait {
            let places = try viewContext.fetch(placesRequest)
            
            places.forEach { viewContext.delete($0) }
            
            if viewContext.hasChanges {
                try viewContext.save()
            }
        }
    }
    
    
    func deleteAll() throws {
        try viewContext.performAndWait {
            let entityNames = ["RequestedRegionEntity", "MapActivityEntity", "UserEntity", "PlaceEntity"]
            
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                batchDeleteRequest.resultType = .resultTypeCount
                
                do {
                    let batchDeleteResult = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
#if DEBUG
                    print("Deleted \(batchDeleteResult?.result ?? 0) records from \(entityName)")
#endif
                } catch {
                    presentErrorToast(error, debug: "Error deleting entity \(entityName): \(error)", silent: true)
                }
            }
            
            try viewContext.save()
        }
    }
    
    func saveUser(userEssentials: UserEssentials) throws {
        try viewContext.performAndWait {
            let user = try self.fetchUser(withID: userEssentials.id) ?? UserEntity(context: viewContext)
            
            self.updateUserEntity(user, with: userEssentials)
            if viewContext.hasChanges {
                try viewContext.save()
            }
        }
    }
    
    func saveUsers(userEssentialsList: [UserEssentials]) throws {
        guard !userEssentialsList.isEmpty else { return }
        
        let ids = Set(userEssentialsList.compactMap { $0.id })
        let context = viewContext
        
        try context.performAndWait {
            let existingUsers = try self.fetchUsers(withIDs: ids)
            let existingUsersDict = Dictionary(uniqueKeysWithValues: existingUsers.compactMap { ($0.id, $0) })
            
            for essentials in userEssentialsList {
                let user = existingUsersDict[essentials.id] ?? UserEntity(context: context)
                self.updateUserEntity(user, with: essentials)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    // MARK: Private methods
    
    private func fetchUser(withID id: String) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
    
    private func fetchUsers(withIDs ids: Set<String>) throws -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        return try viewContext.fetch(request)
    }
    
    private func updateUserEntity(_ user: UserEntity, with essentials: UserEssentials) {
        user.id = essentials.id
        user.name = essentials.name
        user.username = essentials.username
        user.verified = essentials.verified
        user.isPrivate = essentials.isPrivate
        user.profileImage = essentials.profileImage?.absoluteString
        user.level = Int16(essentials.progress.level)
        user.xp = Int16(essentials.progress.xp)
        user.savedAt = Date()
    }
}
