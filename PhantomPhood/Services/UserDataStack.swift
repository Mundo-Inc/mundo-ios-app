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
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
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
