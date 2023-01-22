//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 27/09/2022.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore,FeedImageDataStore {
    
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL:Data] = [:]
    
    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        feedCache = CachedFeed(feed: feed,timestamp: timestamp)
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }
    
    func insert(data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [],timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [],timestamp: Date()))
    }
}

