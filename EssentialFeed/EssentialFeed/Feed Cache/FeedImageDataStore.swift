//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?,Error>
    
    func retrieve(dataForURL url: URL,completion: @escaping ((Result) -> Void))
}
