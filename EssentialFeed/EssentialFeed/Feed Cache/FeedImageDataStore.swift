//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(data: Data,for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
