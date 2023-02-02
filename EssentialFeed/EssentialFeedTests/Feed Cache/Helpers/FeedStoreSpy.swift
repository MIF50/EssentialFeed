//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 17/03/2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    private var deletionResult: Result<Void,Error>?
    private var insertionResult: Result<Void,Error>?
    private var retrievalResult: Result<CachedFeed?,Error>?
        
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage],Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: NSError,at index: Int = 0) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionResult = .success(())
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(feed, timestamp))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: NSError,at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func retrieve() throws -> CachedFeed? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: NSError,at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage],timestamp: Date
                           ,at index: Int = 0) {
        retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
    }
}
