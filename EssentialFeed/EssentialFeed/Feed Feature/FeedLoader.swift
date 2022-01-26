//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 07/01/2022.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping ((LoadFeedResult<Self.Error>)-> Void))
}
