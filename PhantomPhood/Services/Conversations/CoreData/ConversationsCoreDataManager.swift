//
//  ConversationsCoreDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation
import CoreData

final class ConversationsCoreDataManager {
    static let shared = ConversationsCoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ConversationsDataContainer")
        
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
    
    /// Deletes: PersistentConversationDataItem, PersistentMediaDataItem, PersistentMessageDataItem, PersistentParticipantDataItem
    func deleteAll() throws {
        let context = viewContext
        
        try context.performAndWait {
            let entityNames = ["PersistentConversationDataItem", "PersistentMediaDataItem", "PersistentMessageDataItem", "PersistentParticipantDataItem"]
            
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                batchDeleteRequest.resultType = .resultTypeCount
                
                do {
                    let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
#if DEBUG
                    print("Deleted \(batchDeleteResult?.result ?? 0) records from \(entityName)")
#endif
                } catch {
                    presentErrorToast(error, debug: "Error deleting entity \(entityName): \(error)", silent: true)
                    context.rollback()  // Important to maintain integrity in case of failure
                    throw error
                }
            }
            
            // Save context to persist changes
            do {
                try context.save()
            } catch {
                presentErrorToast(error, debug: "Failed to save context", silent: true)
                context.rollback()
                throw error
            }
        }
    }
    
    func saveContext() async throws {
        try await viewContext.perform {
            if self.viewContext.hasChanges {
                try self.viewContext.save()
            }
        }
    }
}
