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
    
    // MARK: - Core Data Saving support
    
    func saveContext() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
