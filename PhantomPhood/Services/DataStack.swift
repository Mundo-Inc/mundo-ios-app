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
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func removeRequestedRegions() throws {
        let fetchedRegionsRequest: NSFetchRequest<RequestedRegionEntity> = RequestedRegionEntity.fetchRequest()
        
        let fetchedRegions = try persistentContainer.viewContext.fetch(fetchedRegionsRequest)
        
        fetchedRegions.forEach { persistentContainer.viewContext.delete($0) }
        
        try saveContext()
    }
    
    func removeMapActivities() throws {
        let mapActivitiesRequest: NSFetchRequest<MapActivityEntity> = MapActivityEntity.fetchRequest()
        
        let mapActivities = try persistentContainer.viewContext.fetch(mapActivitiesRequest)
        
        mapActivities.forEach { persistentContainer.viewContext.delete($0) }
        
        try saveContext()
    }
    
    func removeUsers() throws {
        let usersRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        let users = try persistentContainer.viewContext.fetch(usersRequest)
        
        users.forEach { persistentContainer.viewContext.delete($0) }
        
        try saveContext()
    }
    
    func removePlaces() throws {
        let placesRequest: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        
        let places = try persistentContainer.viewContext.fetch(placesRequest)
        
        places.forEach { persistentContainer.viewContext.delete($0) }
        
        try saveContext()
    }
    
    func deleteAll() throws {
        try? removeRequestedRegions()
        try? removeMapActivities()
        try? removeUsers()
        try? removePlaces()
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
            print("DEBUG: Error saving user infor to CoreData", error)
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() throws {
        viewContext.perform {
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                } catch let error as NSError {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
}
