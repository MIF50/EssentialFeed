//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/09/2022.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Result<Data?,Error>
    typealias InsertionResult = Result<Void,Error>
    
    func insert(data: Data,for url: URL,completion: @escaping ((InsertionResult) -> Void))
    func retrieve(dataForURL url: URL,completion: @escaping ((RetrievalResult) -> Void))
}
