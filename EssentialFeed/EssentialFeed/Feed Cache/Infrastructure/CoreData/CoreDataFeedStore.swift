//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 02/04/2022.
//

import CoreData

public class CoreDataFeedStore {
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    enum StoreError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(modelName: Self.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentStores(error)
        }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R,Error>) throws -> R {
        let context = self.context
        var result: Result<R,Error>!
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}
