//
//  NullStore.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 06/01/2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL, completion: @escaping ((InsertionResult) -> Void)) {
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        completion(.success(.none))
    }
}