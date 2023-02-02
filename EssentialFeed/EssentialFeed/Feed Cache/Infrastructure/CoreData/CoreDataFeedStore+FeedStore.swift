//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result(catching: {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed,timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result(catching: {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.image(from: feed,in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result(catching: {
                try ManagedCache.deleteCache(in: context)
            })
        }
    }
}
