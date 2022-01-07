//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 07/01/2022.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult)-> Void))
}
