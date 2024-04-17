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
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = PersistentConversationDataItem.fetchRequest()
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = PersistentMediaDataItem.fetchRequest()
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        let fetchRequest3: NSFetchRequest<NSFetchRequestResult> = PersistentMessageDataItem.fetchRequest()
        let deleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        
        let fetchRequest4: NSFetchRequest<NSFetchRequestResult> = PersistentParticipantDataItem.fetchRequest()
        let deleteRequest4 = NSBatchDeleteRequest(fetchRequest: fetchRequest4)
        
        do {
            try viewContext.execute(deleteRequest1)
            try viewContext.execute(deleteRequest2)
            try viewContext.execute(deleteRequest3)
            try viewContext.execute(deleteRequest4)
        } catch {
            presentErrorToast(error, debug: "Error deleting all conversations", silent: true)
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
        
    func saveContext() throws {
        viewContext.perform {
            if self.viewContext.hasChanges {
                Task {
                    await MainActor.run {
                        do {
                            try self.viewContext.save()
                        } catch {
                            presentErrorToast(error, silent: true)
                        }
                    }
                }
            }
        }
    }
}
