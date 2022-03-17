//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 16/03/2022.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?)-> Void)
    typealias InsertionCompletion = ((Error?)-> Void)
    typealias RetrievalCompletion = ((Error?) -> Void)

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func save(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
