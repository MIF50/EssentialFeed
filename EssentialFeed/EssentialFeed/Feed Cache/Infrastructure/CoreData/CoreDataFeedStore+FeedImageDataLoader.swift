//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(data: Data, for url: URL, completion: @escaping ((FeedImageDataStore.InsertionResult) -> Void)) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        completion(.success(.none))
    }
    
}
