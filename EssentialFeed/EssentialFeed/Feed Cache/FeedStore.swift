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

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func save(_ items: [FeedItem],timestamp: Date,completion: @escaping InsertionCompletion)
}
