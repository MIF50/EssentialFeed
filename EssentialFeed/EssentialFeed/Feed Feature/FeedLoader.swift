//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 07/01/2022.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage],Error>

public protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult)-> Void))
}
