//
//  CDPublisher.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/21/24.
//

import Combine
import CoreData
import Foundation

// Inspired by: https://gist.github.com/agiokas/d6db64a9c7ed44c019e5f95f5cfeee56
final class CDPublisher<Entity>: NSObject, NSFetchedResultsControllerDelegate, Publisher where Entity: NSManagedObject {
    typealias Output = [Entity]
    typealias Failure = Error
    
    private let request: NSFetchRequest<Entity>
    private let context: NSManagedObjectContext
    private let subject: CurrentValueSubject<[Entity], Failure>
    private var resultController: NSFetchedResultsController<Entity>?
    private var subscriptions = 0
    
    private let queue = DispatchQueue(label: "\(K.ENV.BundleIdentifier).CDPublisher", qos: .userInitiated)
    
    init(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
        if request.sortDescriptors == nil {
            request.sortDescriptors = []
        }
        
        self.request = request
        self.context = context
        self.subject = CurrentValueSubject([])
        super.init()
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, any Failure == S.Failure, [Entity] == S.Input {
        let start = queue.sync {
            subscriptions += 1
            return subscriptions == 1
        }
        
        if start {
            startFetching()
        }
        
        CDSubscription(fetchPublisher: self, subscriber: AnySubscriber(subscriber))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        let result = controller.fetchedObjects as? [Entity] ?? []
        subject.send(result)
    }
    
    private func startFetching() {
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        context.performAndWait { [weak self] in
            do {
                Swift.print("performFetch")
                try controller.performFetch()
                let result = controller.fetchedObjects ?? []
                Swift.print("performFetch result \(result.count)")
                self?.subject.send(result)
            } catch {
                self?.subject.send(completion: .failure(error))
            }
        }
        
        resultController = controller
    }
    
    private func dropSubscription() {
        let stop = queue.sync {
            subscriptions -= 1
            return subscriptions == 0
        }
        
        if stop {
            resultController?.delegate = nil
            resultController = nil
        }
    }
    
    private class CDSubscription: Subscription {
        private weak var fetchPublisher: CDPublisher?
        private var cancellable: AnyCancellable?
        
        @discardableResult
        init(fetchPublisher: CDPublisher, subscriber: AnySubscriber<Output, Failure>) {
            self.fetchPublisher = fetchPublisher
            
            subscriber.receive(subscription: self)
            
            cancellable = fetchPublisher.subject.sink(receiveCompletion: { completion in
                subscriber.receive(completion: completion)
            }, receiveValue: { value in
                _ = subscriber.receive(value)
            })
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            cancellable?.cancel()
            cancellable = nil
            fetchPublisher?.dropSubscription()
            fetchPublisher = nil
        }
    }
}
