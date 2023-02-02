//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 17/09/2022.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
