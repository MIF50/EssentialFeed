//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 07/01/2022.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage],Error>

    func load(completion: @escaping ((Result)-> Void))
}
