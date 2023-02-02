//
//  NullStore.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 06/01/2023.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    
    func deleteCachedFeed() throws {}
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws { }
    
    func retrieve() throws -> CachedFeed? { .none }
   
    func insert(data: Data, for url: URL) throws {}
    
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
