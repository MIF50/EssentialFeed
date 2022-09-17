//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 17/09/2022.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void,Error>
    
    func save(_ feed: [FeedImage],completion: @escaping ((Result)-> Void))
}
