//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 16/03/2022.
//

import Foundation

public enum RetrieveCacheFeedResult {
    case found(feed: [LocalFeedImage],timestamp: Date)
    case empty
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?)-> Void)
    typealias InsertionCompletion = ((Error?)-> Void)
    typealias RetrievalCompletion = ((RetrieveCacheFeedResult) -> Void)

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func save(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
