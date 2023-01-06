//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(data: Data, for url: URL, completion: @escaping ((FeedImageDataStore.InsertionResult) -> Void)) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping ((FeedImageDataStore.RetrievalResult) -> Void)) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.data(with: url, in: context)
            })
        }
    }
}