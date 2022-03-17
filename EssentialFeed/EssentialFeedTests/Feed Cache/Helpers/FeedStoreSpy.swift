//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 17/03/2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
        
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage],Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: NSError,at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func save(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: NSError,at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieval() {
        receivedMessages.append(.retrieve)
    }
}
