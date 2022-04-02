//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 02/04/2022.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    public init() {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}