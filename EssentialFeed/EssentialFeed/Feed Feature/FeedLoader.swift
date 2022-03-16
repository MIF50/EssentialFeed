//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 07/01/2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult)-> Void))
}
