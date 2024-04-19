//
//  ConversationsCoreDataManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation
import CoreData

final class ConversationsCoreDataManager {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "ConversationsDataContainer")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Deletes: PersistentConversationDataItem, PersistentMediaDataItem, PersistentMessageDataItem, PersistentParticipantDataItem
    func deleteAll(completion: @escaping (Bool) -> Void) {
        let context = viewContext
        
        context.perform {
            let entityNames = ["PersistentConversationDataItem", "PersistentMediaDataItem", "PersistentMessageDataItem", "PersistentParticipantDataItem"]
            
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
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
        
    func saveContext() async throws {
        try await viewContext.perform {
            if self.viewContext.hasChanges {
                try self.viewContext.save()
            }
        }
    }
}
