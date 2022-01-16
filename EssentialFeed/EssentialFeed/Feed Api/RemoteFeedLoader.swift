//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by MIF50 on 15/01/2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL,completion:@escaping ((Error)-> Void))
}

public class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Error)-> Void) = { _ in }) {
        client.get(from: url) { error in
            completion(.invalidData)
        }
    }
}